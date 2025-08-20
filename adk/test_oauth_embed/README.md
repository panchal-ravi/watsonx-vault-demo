# Watson Orchestrate Embedded Test Web App

This is a simple web application to test the Watson Orchestrate embedded script with the following configuration:

## Configuration Details
- **Orchestration ID**: `20250818-2250-0903-906c-a26b84d378cd_20250818-2250-2466-2080-dc6415c827cd`
- **Agent ID**: `e1599f44-6586-4c4c-9690-ad4631508a5a`
- **Agent Environment ID**: `cb24aa31-7d0b-447b-8a4b-116d0ff591a1`
- **Host URL**: `https://dl.watson-orchestrate.ibm.com`

## Files
- `index.html` - Main test page with embedded Watson Orchestrate
- `server.py` - Simple Python HTTP server to serve the web app
- `README.md` - This file

## How to Run

### Option 1: Using the Python Server (Recommended)
1. Run the server:
   ```bash
   python server.py
   ```
   Or specify a custom port:
   ```bash
   python server.py 8080
   ```

2. The server will automatically:
   - Start on `http://localhost:8000` (or your specified port)
   - Try to open your default browser automatically
   - Display the test page at `/index.html`

3. Press `Ctrl+C` to stop the server

### Option 2: Using Python's Built-in Server
If you prefer using Python's built-in server:
```bash
python -m http.server 8000
```
Then open `http://localhost:8000/index.html` in your browser.

### Option 3: Direct File Access
You can also open `index.html` directly in your browser, but some features might not work due to CORS restrictions.

## What to Expect

1. **Loading Status**: The page shows the loading status of the Watson Orchestrate script
2. **Configuration Display**: Shows the current configuration being used
3. **Chat Widget**: The Watson Orchestrate chat widget should appear in the designated area
4. **Console Logs**: Check browser developer tools for any error messages

## Troubleshooting

- **Script Loading Errors**: Check the browser console for detailed error messages
- **CORS Issues**: Make sure to use the HTTP server rather than opening the file directly
- **Port Conflicts**: If port 8000 is busy, try a different port number
- **Network Issues**: Ensure you have internet access to reach the Watson Orchestrate host

## Testing

Once the page loads:
1. Verify that the Watson Orchestrate widget appears
2. Try interacting with the chat interface
3. Check browser developer tools for any JavaScript errors
4. Monitor network requests to ensure proper communication with Watson Orchestrate

## Notes

- This is a basic test implementation
- For production use, consider proper error handling, authentication, and security measures
- The embedded script configuration should match your Watson Orchestrate setup
