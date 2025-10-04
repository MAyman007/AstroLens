from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, HttpUrl
from typing import List
import uvicorn
import httpx
from bs4 import BeautifulSoup
import re
import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

# Initialize Google Generative AI
def initialize_ai():
    """Initialize the Google Generative AI model."""
    api_key = os.getenv('GOOGLE_API_KEY')
    if not api_key:
        print("Warning: GOOGLE_API_KEY environment variable not set. AI features will be disabled.")
        return None
    
    try:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-2.0-flash-exp')
        return model
    except Exception as e:
        print(f"Error initializing AI model: {e}")
        return None

# Initialize AI model on startup
ai_model = initialize_ai()

app = FastAPI(
    title="Paper Summarizer API",
    description="API for summarizing research papers from URLs with AI-powered summarization",
    version="1.0.0"
)

# Add CORS middleware to allow requests from Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request model
class SummarizeRequest(BaseModel):
    url: HttpUrl

# Response model
class SummarizeResponse(BaseModel):
    title: str
    link: str
    abstract: str
    introduction: str
    materials_methods: str
    results: str
    discussion: str
    simplified_ai_version: str

def extract_text_content(soup):
    """Extract clean text content from BeautifulSoup object."""
    # Remove script and style elements
    for script in soup(["script", "style"]):
        script.extract()
    
    # Get text and clean it up
    text = soup.get_text()
    # Break into lines and remove leading/trailing space
    lines = (line.strip() for line in text.splitlines())
    # Break multi-headlines into a line each
    chunks = (phrase.strip() for line in lines for phrase in line.split("  "))
    # Drop blank lines
    text = ' '.join(chunk for chunk in chunks if chunk)
    return text

def extract_keywords_from_text(text, max_keywords=10):
    """Extract simple keywords from text (basic implementation)."""
    # This is a very basic keyword extraction
    # In production, you'd use NLP libraries like spaCy or NLTK
    
    # Common stop words to filter out
    stop_words = {
        'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with',
        'by', 'from', 'up', 'about', 'into', 'through', 'during', 'before', 'after',
        'above', 'below', 'between', 'among', 'is', 'are', 'was', 'were', 'be', 'been',
        'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could',
        'should', 'may', 'might', 'must', 'can', 'this', 'that', 'these', 'those'
    }
    
    # Extract words and filter
    words = re.findall(r'\b[a-zA-Z]{3,}\b', text.lower())
    word_freq = {}
    for word in words:
        if word not in stop_words:
            word_freq[word] = word_freq.get(word, 0) + 1
    
    # Get most frequent words as keywords
    keywords = sorted(word_freq.items(), key=lambda x: x[1], reverse=True)
    return [word for word, freq in keywords[:max_keywords]]

async def generate_ai_summary_and_keywords(text_content):
    """Use AI to generate summary and keywords for space biology content."""
    if not ai_model or not text_content.strip():
        return None, None
    
    try:
        # Create prompt for AI
        prompt = f"""
        Summarize this space biology paper in simple language for non-experts. Also list 5-8 keywords.

        Content:
        {text_content[:3000]}  # Limit content to avoid token limits

        Please format your response as:
        SUMMARY: [Your summary here - make it accessible to non-experts, focusing on the main findings and implications]

        KEYWORDS: [keyword1, keyword2, keyword3, keyword4, keyword5]

        Guidelines:
        - Keep the summary under 300 words
        - Use simple, clear language that a general audience can understand
        - Focus on what was studied, what was found, and why it matters
        - Keywords should be relevant scientific terms related to space biology
        """
        
        # Generate content using AI
        response = ai_model.generate_content(prompt)
        
        # Check if response is empty or invalid
        if not response or not hasattr(response, 'text') or not response.text:
            print("Warning: AI model returned empty response")
            return None, None
            
        ai_text = response.text.strip()
        if not ai_text:
            print("Warning: AI model returned empty text")
            return None, None
        
        # Parse the response
        summary = ""
        keywords = []
        
        # Extract summary
        summary_match = re.search(r'SUMMARY:\s*(.*?)(?=KEYWORDS:|$)', ai_text, re.DOTALL | re.IGNORECASE)
        if summary_match:
            summary = summary_match.group(1).strip()
        
        # Extract keywords
        keywords_match = re.search(r'KEYWORDS:\s*(.*?)$', ai_text, re.DOTALL | re.IGNORECASE)
        if keywords_match:
            keywords_text = keywords_match.group(1).strip()
            # Parse keywords - handle different formats
            keywords_text = keywords_text.replace('[', '').replace(']', '')
            keywords = [kw.strip() for kw in re.split(r'[,\n]', keywords_text) if kw.strip()]
            # Clean up keywords and limit to 8
            keywords = [kw for kw in keywords if len(kw) > 2][:8]
        
        # Validate results
        if not summary or not keywords:
            print(f"Warning: Failed to parse AI response properly. Summary: {bool(summary)}, Keywords: {len(keywords)}")
            return None, None
        
        return summary, keywords
        
    except Exception as e:
        print(f"Error generating AI summary: {e}")
        return None, None

async def generate_simplified_summary(abstract, introduction, materials_methods, results, discussion):
    """Generate simplified summary using AI."""
    if not ai_model:
        return "AI summarization not available."
    
    try:
        # Combine all sections
        combined_text = f"Abstract: {abstract}\n\nIntroduction: {introduction}\n\nMaterials and Methods: {materials_methods}\n\nResults: {results}\n\nDiscussion: {discussion}"
        
        # Truncate if too long
        if len(combined_text) > 3000:
            combined_text = combined_text[:3000]
        
        prompt = f"""
        Please create a simplified summary of this scientific paper for non-experts. 
        Explain the research in simple terms that anyone can understand.
        
        Paper content:
        {combined_text}
        
        Write a clear, engaging summary that explains:
        1. What the researchers studied
        2. How they did it (methods)
        3. What they found
        4. Why it matters
        
        Use simple language and avoid technical jargon. Keep it under 300 words.
        """
        
        # Generate content using AI
        response = ai_model.generate_content(prompt)
        
        if response and hasattr(response, 'text') and response.text:
            return response.text.strip()
        else:
            return "AI could not generate summary."
            
    except Exception as e:
        print(f"Error generating simplified summary: {e}")
        return f"Error generating simplified summary: {str(e)}"

async def parse_pmc_xml_content(xml_content, original_url):
    """Parse PMC XML content from E-utilities API."""
    try:
        print("DEBUG: Parsing PMC XML content...")
        
        # Parse XML with BeautifulSoup
        soup = BeautifulSoup(xml_content, 'xml')
        
        # Extract title
        title = "Untitled PMC Article"
        title_group = soup.find('title-group')
        if title_group:
            article_title = title_group.find('article-title')
            if article_title:
                title = article_title.get_text().strip()
        
        print(f"DEBUG: Extracted title: {title}")
        
        # Extract abstract
        abstract = ""
        abstract_element = soup.find('abstract')
        if abstract_element:
            # Remove any nested tags and get clean text
            for tag in abstract_element(['title', 'label']):
                tag.decompose()
            abstract = abstract_element.get_text().strip()
        
        print(f"DEBUG: Extracted abstract length: {len(abstract)} chars")
        
        # Extract specific sections
        introduction = ""
        materials_methods = ""
        results = ""
        discussion = ""
        
        # Look for sections in the body
        body = soup.find('body')
        if body:
            # Find sections by title
            sections = body.find_all('sec')
            
            for section in sections:
                # Get section title
                section_title = ""
                title_element = section.find('title')
                if title_element:
                    section_title = title_element.get_text().strip().lower()
                
                # Remove title from section content
                section_copy = section.__copy__()
                if section_copy.find('title'):
                    section_copy.find('title').decompose()
                
                # Remove references, figures, tables
                for unwanted in section_copy(['ref-list', 'fig', 'table-wrap', 'fn-group', 'ref']):
                    unwanted.decompose()
                
                section_text = section_copy.get_text().strip()
                section_text = ' '.join(section_text.split())  # Normalize whitespace
                
                # Categorize sections
                if any(keyword in section_title for keyword in ['introduction', 'background', 'intro']):
                    introduction = section_text
                    print(f"DEBUG: Found introduction section: {len(introduction)} chars")
                elif any(keyword in section_title for keyword in ['material', 'method', 'procedure', 'experimental']):
                    materials_methods = section_text
                    print(f"DEBUG: Found materials/methods section: {len(materials_methods)} chars")
                elif any(keyword in section_title for keyword in ['result', 'finding', 'outcome']):
                    results = section_text
                    print(f"DEBUG: Found results section: {len(results)} chars")
                elif any(keyword in section_title for keyword in ['discussion', 'conclusion', 'implication']):
                    discussion = section_text
                    print(f"DEBUG: Found discussion section: {len(discussion)} chars")
        
        # If sections not found by title, try to extract from paragraphs
        if not introduction or not materials_methods or not results or not discussion:
            print("DEBUG: Attempting to extract sections from paragraph content...")
            all_paragraphs = body.find_all('p') if body else []
            
            for para in all_paragraphs:
                para_text = para.get_text().strip()
                
                # Simple heuristics to identify sections
                if not introduction and len(para_text) > 100:
                    introduction = para_text
                elif not materials_methods and any(word in para_text.lower()[:50] for word in ['material', 'method', 'procedure', 'protocol']):
                    materials_methods = para_text
                elif not results and any(word in para_text.lower()[:50] for word in ['result', 'finding', 'observed', 'measured']):
                    results = para_text
                elif not discussion and any(word in para_text.lower()[:50] for word in ['discussion', 'conclusion', 'suggest', 'implication']):
                    discussion = para_text
        
        # Generate simplified summary using AI
        simplified_summary = await generate_simplified_summary(abstract, introduction, materials_methods, results, discussion)
        
        response_data = SummarizeResponse(
            title=title,
            link=original_url,
            abstract=abstract,
            introduction=introduction,
            materials_methods=materials_methods,
            results=results,
            discussion=discussion,
            simplified_ai_version=simplified_summary
        )
        
        print(f"DEBUG: PMC XML parsing completed successfully")
        return response_data
        
    except Exception as e:
        print(f"DEBUG: Error parsing PMC XML: {e}")
        raise HTTPException(status_code=500, detail=f"Error parsing PMC content: {str(e)}")

@app.post("/summarize", response_model=SummarizeResponse)
async def summarize_paper(request: SummarizeRequest):
    """
    Summarize a research paper from the provided URL.
    
    Args:
        request: JSON object containing the URL of the paper to summarize
        
    Returns:
        JSON response with paper title, link, summary, keywords, and abstract
    """
    try:
        print(f"DEBUG: Attempting to fetch URL: {request.url}")
        
        # Try multiple strategies for PMC access
        url_str = str(request.url)
        
        # PMC E-utilities API strategy
        if 'pmc.ncbi.nlm.nih.gov' in url_str:
            print("DEBUG: Detected PMC URL, using NCBI E-utilities API...")
            
            # Extract PMC ID from URL
            pmc_id_match = re.search(r'/PMC(\d+)', url_str)
            if pmc_id_match:
                pmc_id = f"PMC{pmc_id_match.group(1)}"
                print(f"DEBUG: Extracted PMC ID: {pmc_id}")
                
                # Get NCBI API key from environment
                ncbi_api_key = os.getenv('NCBI_API_KEY')
                if ncbi_api_key:
                    print(f"DEBUG: Using NCBI API key: {ncbi_api_key[:8]}...")
                    
                    # Build E-utilities URL
                    eutils_url = f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id={pmc_id}&rettype=full&retmode=xml&api_key={ncbi_api_key}"
                    
                    print(f"DEBUG: E-utilities URL: {eutils_url}")
                    
                    try:
                        headers = {
                            'User-Agent': 'AstroLens-PaperSummarizer/1.0 (contact@example.com)',
                            'Accept': 'application/xml, text/xml, */*',
                        }
                        
                        async with httpx.AsyncClient(timeout=60.0) as client:
                            response = await client.get(eutils_url, headers=headers)
                            
                            print(f"DEBUG: E-utilities response status: {response.status_code}")
                            print(f"DEBUG: E-utilities content length: {len(response.content)} bytes")
                            print(f"DEBUG: E-utilities content preview: {response.text[:500]}")
                            
                            if response.status_code == 200 and len(response.content) > 100:
                                print("DEBUG: SUCCESS! Got PMC content via E-utilities API")
                                # Parse XML content instead of HTML
                                return await parse_pmc_xml_content(response.content, str(request.url))
                            else:
                                print("DEBUG: E-utilities failed, falling back to generic approach")
                                
                    except Exception as e:
                        print(f"DEBUG: E-utilities failed with error: {e}")
                else:
                    print("DEBUG: No NCBI_API_KEY found in environment, skipping E-utilities")
            else:
                print("DEBUG: Could not extract PMC ID from URL")
            
            # Fall back to generic approach if E-utilities failed
            response = None
        
        # Generic approach for non-PMC URLs or if PMC strategies failed
        if not response:
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.9',
                'Accept-Encoding': 'gzip, deflate, br',
                'Connection': 'keep-alive',
                'Upgrade-Insecure-Requests': '1',
            }
            
            print(f"DEBUG: Using generic approach for: {url_str}")
            
            async with httpx.AsyncClient(timeout=30.0, follow_redirects=True) as client:
                response = await client.get(url_str, headers=headers)
                
                print(f"DEBUG: Response status: {response.status_code}")
                print(f"DEBUG: Content length: {len(response.content)} bytes")
        
        print(f"DEBUG: Final response preview (first 500 chars): {response.text[:500]}")
        response.raise_for_status()
        
        # Parse the HTML content
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Extract title
        title = "Untitled Document"
        title_tag = soup.find('title')
        if title_tag:
            title = title_tag.get_text().strip()
        
        # Look for meta title as backup
        if not title or title == "Untitled Document":
            meta_title = soup.find('meta', property='og:title')
            if meta_title:
                title = meta_title.get('content', '').strip()
        
        # Extract abstract - try multiple approaches
        abstract = ""
        
        # Method 1: Look for meta description
        meta_desc = soup.find('meta', attrs={'name': 'description'})
        if meta_desc:
            abstract = meta_desc.get('content', '').strip()
        
        # Method 2: Look for OpenGraph description
        if not abstract:
            og_desc = soup.find('meta', property='og:description')
            if og_desc:
                abstract = og_desc.get('content', '').strip()
        
        # Method 3: Look for abstract section in body
        if not abstract:
            abstract_section = soup.find(['div', 'section', 'p'], class_=re.compile(r'abstract', re.I))
            if abstract_section:
                abstract = extract_text_content(abstract_section)[:500]
        
        # Method 4: Look for abstract by ID
        if not abstract:
            abstract_by_id = soup.find(id=re.compile(r'abstract', re.I))
            if abstract_by_id:
                abstract = extract_text_content(abstract_by_id)[:500]
        
        # Method 5: Look for first paragraph that might be abstract
        if not abstract:
            paragraphs = soup.find_all('p')
            for p in paragraphs[:5]:  # Check first 5 paragraphs
                text = p.get_text().strip()
                if len(text) > 100:  # Substantial paragraph
                    abstract = text[:500]
                    break
        
        # Fallback: Use first 500 characters of body text
        if not abstract:
            body_text = extract_text_content(soup)
            abstract = body_text[:500] if body_text else "No content available"
        
        # Extract specific sections from HTML content
        introduction = ""
        materials_methods = ""
        results = ""
        discussion = ""
        
        # Try to find sections by headers or content patterns
        all_text = extract_text_content(soup)
        paragraphs = soup.find_all(['p', 'div', 'section'])
        
        for element in paragraphs:
            text = element.get_text().strip()
            if len(text) < 50:  # Skip short elements
                continue
                
            # Check for section indicators
            text_lower = text.lower()
            
            # Look for introduction section
            if not introduction and any(indicator in text_lower[:100] for indicator in ['introduction', 'background', 'overview']):
                introduction = text[:1000]  # Limit length
                print(f"DEBUG: Found introduction section in HTML: {len(introduction)} chars")
            
            # Look for materials/methods section
            elif not materials_methods and any(indicator in text_lower[:100] for indicator in ['materials', 'methods', 'methodology', 'procedure', 'experimental']):
                materials_methods = text[:1000]
                print(f"DEBUG: Found materials/methods section in HTML: {len(materials_methods)} chars")
            
            # Look for results section
            elif not results and any(indicator in text_lower[:100] for indicator in ['results', 'findings', 'outcomes', 'data show']):
                results = text[:1000]
                print(f"DEBUG: Found results section in HTML: {len(results)} chars")
            
            # Look for discussion section
            elif not discussion and any(indicator in text_lower[:100] for indicator in ['discussion', 'conclusion', 'implications', 'suggest']):
                discussion = text[:1000]
                print(f"DEBUG: Found discussion section in HTML: {len(discussion)} chars")
        
        # If sections still not found, extract from general content
        if not introduction or not materials_methods or not results or not discussion:
            print("DEBUG: Using fallback content extraction for missing sections...")
            paragraphs_text = [p.get_text().strip() for p in soup.find_all('p') if len(p.get_text().strip()) > 100]
            
            if not introduction and len(paragraphs_text) > 0:
                introduction = paragraphs_text[0][:1000]
            if not materials_methods and len(paragraphs_text) > 1:
                materials_methods = paragraphs_text[1][:1000]
            if not results and len(paragraphs_text) > 2:
                results = paragraphs_text[2][:1000]
            if not discussion and len(paragraphs_text) > 3:
                discussion = paragraphs_text[3][:1000]
        
        # Generate simplified summary using AI
        simplified_summary = await generate_simplified_summary(abstract, introduction, materials_methods, results, discussion)
        
        response_data = SummarizeResponse(
            title=title,
            link=str(request.url),
            abstract=abstract,
            introduction=introduction,
            materials_methods=materials_methods,
            results=results,
            discussion=discussion,
            simplified_ai_version=simplified_summary
        )
        
        return response_data
        
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=400, detail=f"HTTP error fetching URL: {e.response.status_code} - {str(e)}")
    except httpx.TimeoutException as e:
        raise HTTPException(status_code=400, detail=f"Timeout fetching URL: {str(e)}")
    except httpx.RequestError as e:
        raise HTTPException(status_code=400, detail=f"Network error fetching URL: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing request: {str(e)}")

@app.get("/")
async def root():
    """Root endpoint providing API information."""
    return {
        "message": "Paper Summarizer API",
        "version": "1.0.0",
        "endpoints": {
            "/summarize": "POST - Summarize a research paper from URL",
            "/summarize-get": "GET - Summarize a research paper from URL (browser-friendly)"
        }
    }

@app.get("/summarize-get")
async def summarize_paper_get(url: str):
    """
    Browser-friendly GET endpoint for summarizing papers.
    
    Usage: http://localhost:8000/summarize-get?url=https://example.com/paper
    """
    try:
        # Validate URL format
        from pydantic import HttpUrl, ValidationError
        try:
            validated_url = HttpUrl(url)
        except ValidationError:
            raise HTTPException(status_code=422, detail="Invalid URL format")
        
        # Create request object and use the existing logic
        request = SummarizeRequest(url=validated_url)
        return await summarize_paper(request)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing request: {str(e)}")

@app.get("/favicon.ico")
async def favicon():
    """Favicon endpoint to prevent 404 errors."""
    return {"message": "No favicon"}

@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "service": "paper-summarizer-api"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=9000)
