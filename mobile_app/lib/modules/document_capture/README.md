# Document Capture Module

Handles document acquisition and preparation before upload.

## Responsibilities

- Launch native multi-page document scanning on Android.
- Persist scanner outputs locally for later processing.
- Let the user review, reorder, rotate, and remove scanned pages.
- Optimize large images before PDF generation.
- Generate a single PDF in page order.
- Extract OCR text per page and aggregate it for AI search.
- Return a final `CapturedDocument` with PDF bytes, local path, OCR, chunks, and metadata.

## Internal separation

- `data/services/native_document_scanner_service.dart`
  Opens the ML Kit scanner UI and returns scanned page paths.
- `data/services/document_page_image_processor.dart`
  Runs image optimization and rotation in a background isolate.
- `data/services/document_pdf_service.dart`
  Builds the final PDF from processed page images.
- `data/services/document_ocr_service.dart`
  Applies ML Kit OCR and produces document-level chunks.
- `presentation/pages/document_scan_editor_page.dart`
  Review screen for reordering, rotating, deleting, and final generation.

## Notes

- The scanner implementation uses `google_mlkit_document_scanner`, which currently supports Android only.
- OCR uses `google_mlkit_text_recognition`.
- The produced output is ready to upload to the existing backend and also exposes a searchable local payload for future AI indexing.
