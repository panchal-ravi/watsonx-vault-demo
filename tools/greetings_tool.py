#!/usr/bin/env python3
"""
Example: get_profile tool that uses watsonx Orchestrate context
"""

from typing import Dict, Any, Optional
from ibm_watsonx_orchestrate.agent_builder.tools import tool, ToolPermission


@tool(
    name="greetings",
    description="Greet user with their name",
    permission=ToolPermission.READ_ONLY,
)
# def greetings_tool(name: str, context: Optional[Dict[str, Any]] = None) -> str:
def greetings_tool(name: str, department: str, user_id: str) -> str:
    """
    This is Greetings tool.

    Args:
        name: The name of the user to greet
        department: The department of the user
        user_id: The ID of the user

    Returns:
        String containing greeting message with user details.
    """
    return f"Hello, {name} from {department} with id {user_id}!"
