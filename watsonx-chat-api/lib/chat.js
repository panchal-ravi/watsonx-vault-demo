// COMPLETE WATSON CHAT IMPLEMENTATION
// This is everything you need to chat with watsonx Orchestrate

export class SimpleWatsonChat {
  constructor() {
    this.apiUrl = '/api/chat'; // Your backend API endpoint
  }

  // Main method to send a message and get streaming response
  async sendMessage(message, userProfile, onUpdate) {
    try {
      // Call your backend API
      const response = await fetch(this.apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: message,
          profileId: userProfile.id
        })
      });

      if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
      }

      // Handle streaming response
      const reader = response.body.getReader();
      const decoder = new TextDecoder();
      let fullResponse = '';

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value);
        console.log("Stream chunk:", chunk);
        const lines = chunk.split('\n');

        for (const line of lines) {
          if (line.startsWith('data: ')) {
            const data = line.slice(6).trim();
            if (!data) continue;

            try {
              const delta = JSON.parse(data);
              console.log("Parsed message:", data);
              
              // Handle different message types
              // switch (message.type) {
              message = delta.choices[0].delta
              console.log("Message delta:", message)

              if(message.step_details && message.step_details.type === 'tool_calls') {
                  const toolName = message.step_details.tool_calls[0].name || {};
                  const args = message.step_details.tool_calls[0].args || {};
                  onUpdate({
                    type: 'tool_activity',
                    content: `🔧 Using ${toolName} tool with args: ${JSON.stringify(args)}`,
                    args: args
                  });
              } else if (message.step_details && message.step_details.type === 'tool_response') {
                  const result =message.step_details.content;
                  onUpdate({
                    type: 'tool_result',
                    content: result,
                    result: result
                  });
              } else {
                if (message.content) {
                  onUpdate({
                    type: 'response',
                    content: message.content,
                    isComplete: true
                  });
                }
              }

              // switch (message.choices[0].delta) {
              //   case 'message_chunk':
              //     // Watson is sending part of the response
              //     const content = message.data?.content || message.content || '';
              //     fullResponse += content;
              //     onUpdate({
              //       type: 'response',
              //       content: fullResponse,
              //       isComplete: false
              //     });
              //     break;

              //   case 'tool_call':
              //     // Watson is using a tool
              //     const toolName = message.data.name;
              //     const args = message.data.args || {};
              //     onUpdate({
              //       type: 'tool_activity',
              //       content: `🔧 Using ${toolName} tool`,
              //       args: args
              //     });
              //     break;

              //   case 'tool_response':
              //     // Tool finished
              //     const result = message.data.content;
              //     onUpdate({
              //       type: 'tool_result',
              //       content: `📊 ${message.data.name} completed`,
              //       result: result
              //     });
              //     break;

              //   case 'complete':
              //     // Watson finished
              //     onUpdate({
              //       type: 'response',
              //       content: fullResponse,
              //       isComplete: true
              //     });
              //     break;

              //   case 'error':
              //     onUpdate({
              //       type: 'error',
              //       content: `❌ Error: ${message.data.message}`
              //     });
              //     break;
              // }
            } catch (parseError) {
              console.log('Skipping invalid message chunk');
            }
          }
        }
      }

      return fullResponse;
    } catch (error) {
      onUpdate({
        type: 'error',
        content: `Connection error: ${error.message}`
      });
      throw error;
    }
  }
}
