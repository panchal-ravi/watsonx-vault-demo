# test_tool.py
from ibm_watsonx_orchestrate.agent_builder.tools import tool, ToolPermission


@tool(
    name="greetings",
    description="Greet user with their name",
    permission=ToolPermission.ADMIN,
)
def greetings_tool(name: str) -> str:
    """
    This is Greetings tool.

    :param name: The name of the user to greet.
    :returns: The greeting message.
    """

    return f"Hello, {name}!"
