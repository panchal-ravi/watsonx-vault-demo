'use client';

import { useEffect, useState, useMemo } from 'react';
import { SimpleWatsonChat } from '../lib/chat.js';

export default function Home() {
  const [message, setMessage] = useState('');
  const [chatResponse, setChatResponse] = useState('');
  const [toolStatus, setToolStatus] = useState('');
  const [toolResult, setToolResult] = useState('');
  const [errorMessage, setErrorMessage] = useState('');
  const [isSending, setIsSending] = useState(false);
  const [dummy, setDummy] = useState(0);

  const watson = useMemo(() => new SimpleWatsonChat(), []);

  const handleSend = async () => {
    if (!message) return;
    setIsSending(true);
    setChatResponse('');
    setToolStatus('');
    setToolResult('');
    setErrorMessage('');

    const userProfile = {
      id: 'sales_rep_profile',
      name: 'Sarah Johnson',
      email: 'sarah@company.com',
      department: 'Sales',
      role: 'Account Manager'
    };

    try {
      await watson.sendMessage(message, userProfile, (update) => {
        console.log("Update type:", update.type);
        console.log("Content:", update.content);
        switch (update.type) {
          case 'response':
            setChatResponse(update.content);
            if (update.isComplete) {
              setIsSending(false);
            }
            break;
          case 'tool_activity':
            setToolStatus(update.content);
            break;
          case 'tool_result':
            setToolResult(update.content);
            break;
          case 'error':
            setErrorMessage(update.content);
            setIsSending(false);
            break;
        }
      });
    } catch (error) {
      setErrorMessage(`Error: ${error.message}`);
      setIsSending(false);
    }
  };

  return (
    <div style={{ fontFamily: 'sans-serif', maxWidth: '600px', margin: 'auto', padding: '20px' }}>
      <h1>Watsonx Chat</h1>
      <div style={{ marginBottom: '20px', display: 'flex' }}>
        <input
          type="text"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && !isSending && handleSend()}
          placeholder="Ask Watson..."
          style={{ flexGrow: 1, padding: '10px', border: '1px solid #ccc', borderRadius: '4px' }}
          disabled={isSending}
        />
        <button onClick={handleSend} disabled={isSending} style={{ padding: '10px 15px', marginLeft: '10px', background: '#007bff', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' }}>
          {isSending ? 'Sending...' : 'Send'}
        </button>
      </div>

      <div style={{ border: '1px solid #eee', padding: '15px', borderRadius: '4px' }}>
        <h3>Response</h3>
        {errorMessage && <p style={{ color: 'red' }}>{errorMessage}</p>}
        {toolStatus && <p style={{ fontStyle: 'italic', color: '#555' }}>{toolStatus}</p>}
        {toolResult && <p style={{ fontStyle: 'italic', color: '#333' }}>{toolResult}</p>}
        <p>{chatResponse}</p>
        {isSending && !chatResponse && <p>Waiting for response...</p>}
      </div>
    </div>
  );
}
