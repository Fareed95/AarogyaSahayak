import json
import os
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from django.conf import settings
from django.core.files.storage import default_storage

from .models import Report, ReportInstance
from utils.usercheck import authenticate_request

# Agents import
from .agents.extracting_basic_details import parse_pdf_auto, update_with_user_response
from .agents.extracting_json_details import extract_medical_from_pdf, generate_report_summary


class ReportView(APIView):

    def post(self, request):
        user = authenticate_request(request, need_user=True)
        if not user:
            return Response({"error": "Unauthorized"}, status=status.HTTP_401_UNAUTHORIZED)

        report_id = request.data.get("report_id")
        answer = request.data.get("answer")
        file = request.FILES.get("file")

        # ---------------------------
        # Case 1: User replying to a question
        # ---------------------------
        if report_id and answer:
            try:
                report = Report.objects.get(id=report_id, user=user)
                instance = report.instances.last()
            except Report.DoesNotExist:
                return Response({"error": "Report not found"}, status=status.HTTP_404_NOT_FOUND)

            # load memory + details
            memory = json.loads(instance.chatMemory or "[]")
            details_dict = instance.json or {}
            from agents.extracting_basic_details import ReportDetails
            details = ReportDetails(**details_dict)

            # update with user response
            updated_details, updated_memory = update_with_user_response(details, memory, answer)

            # save back
            instance.json = updated_details.dict()
            instance.chatMemory = json.dumps([m.dict() for m in updated_memory], default=str)
            instance.save()

            if updated_details.end:  # ✅ All info filled → run JSON + summary pipeline
                page_results = extract_medical_from_pdf(instance.file)
                instance.json = [r.dict() for r in page_results]
                instance.instance_summary = generate_report_summary(page_results)
                instance.name_of_the_doctor = updated_details.doctor_name
                instance.address_of_the_doctor = updated_details.hospital_address
                instance.save()

                report.overall_summary = instance.instance_summary
                report.save()

                return Response({
                    "message": "Report completed",
                    "report_id": report.id,
                    "summary": report.overall_summary
                })

            return Response({
                "message": "Answer received",
                "next_questions": updated_details.questions,
                "report_id": report.id
            })

        # ---------------------------
        # Case 2: New PDF upload
        # ---------------------------
        elif file:
            # get all titles of reports of this user
            diseases = list(Report.objects.filter(user=user).values_list("title", flat=True))

            # save file temporarily
            file_path = default_storage.save(f"reports/{file.name}", file)
            abs_path = os.path.join(settings.MEDIA_ROOT, file_path)

            # parse PDF for basic details
            details, memory = parse_pdf_auto(abs_path, diseases, [])
            print(details)

            # create report + instance
            report = Report.objects.create(user=user, title=file.name)
            instance = ReportInstance.objects.create(
                report=report,
                file=abs_path,
                json=details.dict(),
                chatMemory=json.dumps([m.dict() for m in memory], default=str),
                name_of_the_doctor=details.doctor_name,
                address_of_the_doctor=details.hospital_address
            )

            if details.end:  # ✅ Directly go for JSON + summary
                page_results = extract_medical_from_pdf(abs_path)
                instance.json = [r.dict() for r in page_results]
                instance.instance_summary = generate_report_summary(page_results)
                instance.save()

                report.overall_summary = instance.instance_summary
                report.save()

                return Response({
                    "message": "Report completed",
                    "report_id": report.id,
                    "summary": report.overall_summary
                })

            # ❌ Still missing info
            return Response({
                "message": "Report created, need more info",
                "report_id": report.id,
                "questions": details.questions
            })

        else:
            return Response({"error": "Either file or answer with report_id required"}, status=status.HTTP_400_BAD_REQUEST)
