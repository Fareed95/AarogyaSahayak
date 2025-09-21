# reports/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.core.files.storage import default_storage
from utils.usercheck import authenticate_request
import os

from .models import Report, ReportInstance
from .agents.extracting_basic_details import extract_report_from_pdf, generate_report_summary as generate_basic_summary
from .agents.extracting_json_details import extract_medical_from_pdf, generate_report_summary as generate_json_summary
from .agents.overal_summary import generate_final_summary


class UploadReportView(APIView):
    """
    Upload PDF, extract report details, save to Report & ReportInstance.
    If a report with the same title already exists for the user, only a new instance is created,
    and the report's overall_summary is updated.
    """

    def post(self, request, format=None):
        user = authenticate_request(request, need_user=True)
        title = request.data.get("title", "Untitled Report")
        uploaded_file = request.FILES.get("file")

        if not uploaded_file:
            return Response({"error": "No file provided"}, status=status.HTTP_400_BAD_REQUEST)

        # Check if report with same title already exists for the user
        report, created = Report.objects.get_or_create(user=user, title=title)

        # Save the uploaded PDF temporarily
        temp_path = default_storage.save(f"temp/{uploaded_file.name}", uploaded_file)
        full_path = default_storage.path(temp_path)

        try:
            # -------------------------------
            # Extract structured report details
            # -------------------------------
            page_reports = extract_report_from_pdf(full_path)
            structured_json = [r.dict() for r in page_reports]
            basic_summary = generate_basic_summary(page_reports)

            # -------------------------------
            # Extract test results JSON
            # -------------------------------
            page_results = extract_medical_from_pdf(full_path)
            test_json = [r.dict() for r in page_results]
            test_summary = generate_json_summary(page_results)

            # -------------------------------
            # Polished final summary using OpenAI
            # -------------------------------
            final_summary_text = generate_final_summary(
                basic_details=structured_json[0].get("details") if structured_json else {},
                summary=f"{basic_summary}\n\n{test_summary}"
            )

            # -------------------------------
            # Save ReportInstance (without instance_name)
            # -------------------------------
            instance = ReportInstance.objects.create(
                report=report,
                file=uploaded_file.name,
                json={
                    "structured_details": structured_json,
                    "test_details": test_json
                },
                instance_summary=final_summary_text,
                name_of_the_doctor=page_reports[0].details.doctor_name if page_reports else "",
                address_of_the_doctor=page_reports[0].details.hospital_address if page_reports else ""
            )

            # Update Report's overall_summary
            report.overall_summary = final_summary_text
            report.save()

            return Response({
                "report_id": report.id,
                "instance_id": instance.id,
                "message": "Report uploaded and processed successfully.",
                "final_summary": final_summary_text
            }, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        finally:
            if os.path.exists(full_path):
                os.remove(full_path)
