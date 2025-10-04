# Paper Summarizer API

A FastAPI application that provides endpoints for summarizing research papers from URLs using AI-powered text analysis.

## Features

- **POST /summarize**: Accepts a URL and returns summarized paper information
- **GET /**: Root endpoint with API information
- **GET /health**: Health check endpoint
- **CORS enabled**: Ready for integration with web applications
- **Auto-generated documentation**: Available at `/docs` and `/redoc`

## API Endpoints

### POST /summarize

Summarizes a research paper from the provided URL.

**Request Body:**
```json
{
  "url": "https://example.com/paper.pdf"
}
```

**Response:**
```json
{
  "title": "Paper Title",
  "link": "https://example.com/paper.pdf",
  "summary": "Brief summary of the paper...",
  "keywords": ["keyword1", "keyword2", "keyword3"],
  "abstract": "Full abstract of the paper..."
}
```

**Status Codes:**
- `200 OK`: Successfully processed the request
- `422 Unprocessable Entity`: Invalid URL format
- `500 Internal Server Error`: Server error during processing

### GET /

Returns basic API information and available endpoints.

**Response:**
```json
{
  "message": "Paper Summarizer API",
  "version": "1.0.0",
  "endpoints": {
    "/summarize": "POST - Summarize a research paper from URL"
  }
}
```

### GET /health

Health check endpoint for monitoring.

**Response:**
```json
{
  "status": "healthy",
  "service": "paper-summarizer-api"
}
```

## Installation

1. **Set up environment variables:**
   ```bash
   # For AI-powered summarization, set your Google API key
   export GOOGLE_API_KEY="your_google_api_key_here"
   ```
   
   **Note**: Without the GOOGLE_API_KEY, the API will fall back to basic text extraction without AI summarization.

2. **Install Python dependencies:**
   ```bash
   cd api
   pip install -r requirements.txt
   ```

3. **Run the development server:**
   ```bash
   python main.py
   ```
   
   Or using uvicorn directly:
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

4. **Access the API:**
   - API: http://localhost:8000
   - Interactive docs: http://localhost:8000/docs
   - Alternative docs: http://localhost:8000/redoc

## AI Features

The API includes advanced AI-powered summarization using Google's Generative AI:

- **Intelligent Summarization**: Converts complex scientific content into simple, accessible language
- **Smart Keyword Extraction**: Identifies 5-8 relevant scientific terms
- **Fallback Support**: Works without AI (basic extraction) if API key is not provided
- **Space Biology Focus**: Optimized prompts for space and biological research papers

### How AI Processing Works

1. **Content Extraction**: Scrapes and parses HTML content from the provided URL
2. **Text Processing**: Cleans and prepares text for AI analysis
3. **AI Summarization**: Sends content to Google's Gemini model with specialized prompts
4. **Response Parsing**: Extracts summary and keywords from AI response
5. **Fallback Handling**: Uses basic text extraction if AI fails or is unavailable

## Usage Examples

### Using cURL

```bash
curl -X POST "http://localhost:8000/summarize" \
     -H "Content-Type: application/json" \
     -d '{"url": "https://arxiv.org/abs/2301.00001"}'
```

### Using Python requests

```python
import requests

response = requests.post(
    "http://localhost:8000/summarize",
    json={"url": "https://arxiv.org/abs/2301.00001"}
)

data = response.json()
print(f"Title: {data['title']}")
print(f"Summary: {data['summary']}")
```

### Using JavaScript fetch

```javascript
fetch('http://localhost:8000/summarize', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    url: 'https://arxiv.org/abs/2301.00001'
  })
})
.then(response => response.json())
.then(data => {
  console.log('Title:', data.title);
  console.log('Summary:', data.summary);
});
```

## Development

### Project Structure

```
api/
├── main.py           # FastAPI application
├── requirements.txt  # Python dependencies
└── README.md        # This file
```

### Key Dependencies

- **FastAPI**: Modern, fast web framework for building APIs
- **Uvicorn**: ASGI server for running the application
- **Pydantic**: Data validation using Python type annotations
- **python-multipart**: For handling form data

### Current Implementation

The current implementation returns fake/placeholder data for all requests. This serves as a foundation for integrating with actual paper processing services.

To implement real paper summarization, you would:

1. Add web scraping capabilities to fetch paper content
2. Integrate with AI/ML services for text summarization
3. Implement keyword extraction algorithms
4. Add caching for improved performance
5. Add authentication and rate limiting for production use

## Production Deployment

For production deployment, consider:

1. **Environment Variables**: Use environment variables for configuration
2. **Database**: Add database for caching and logging
3. **Authentication**: Implement API key authentication
4. **Rate Limiting**: Add rate limiting to prevent abuse
5. **Monitoring**: Add logging and monitoring
6. **HTTPS**: Use HTTPS in production
7. **Docker**: Containerize the application

### Example Docker Deployment

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY main.py .
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## License

This project is part of the AstroLens application.
