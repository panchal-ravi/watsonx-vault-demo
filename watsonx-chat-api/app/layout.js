export const metadata = {
  title: "Watsonx Chat",
  description: "Chat with Watsonx Orchestrate",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
