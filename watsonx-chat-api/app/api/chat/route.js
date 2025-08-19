// Backend API route (Next.js example)

let cachedToken = null;

async function getToken() {
  // If we have a valid token in cache, return it
  // (subtract 60 seconds from expiration for safety)
  if (cachedToken && cachedToken.expiration > Date.now() + 60000) {
    return cachedToken.access_token;
  }

  // Otherwise, fetch a new token
  const tokenResponse = await fetch('https://iam.cloud.ibm.com/identity/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=${process.env.IAM_API_KEY}`
  });

  if (!tokenResponse.ok) {
    throw new Error('Failed to fetch IAM token');
  }

  const tokenData = await tokenResponse.json();
  console.log("Fetched new tokenData:", tokenData);

  // Cache the new token with its expiration time
  cachedToken = {
    access_token: tokenData.access_token,
    expiration: Date.now() + (tokenData.expires_in * 1000)
  };

  return cachedToken.access_token;
}


export async function POST(request) {
  const { message, profileId } = await request.json();

  try {
    const bearerToken = await getToken();
    // console.log("Using bearerToken:", bearerToken);

    // 2. Get user context from profile
    const userContext = {
      user_name: 'Sarah Johnson',
      user_email: 'sarah@company.com',
      profile_id: profileId,
      department: 'Sales',
      title: 'Account Manager',
      user_id: bearerToken
    };

    // 3. Call watsonx Orchestrate
    const watsonResponse = await fetch(
      `https://api.au-syd.watson-orchestrate.cloud.ibm.com/instances/${process.env.WATSONX_INSTANCE_ID}/v1/orchestrate/${process.env.WATSONX_AGENT_ID}/chat/completions`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': `Bearer ${bearerToken}`,
          'X-Session-ID': `session_${Date.now()}`,
          'X-Conversation-ID': `conv_${Date.now()}`
        },
        body: JSON.stringify({
          messages: [{ role: 'user', content: message }],
          agent_id: process.env.WATSONX_AGENT_ID,
          context: userContext,
          stream: true
        })
      }
    );

    if (!watsonResponse.ok) {
      console.error("Watson API Error:", await watsonResponse.text());
      throw new Error(`Watson API responded with status ${watsonResponse.status}`);
    }

    // 4. Return streaming response to frontend
    return new Response(watsonResponse.body, {
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive'
      }
    });

  } catch (error) {
    console.error("Error in chat API:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
