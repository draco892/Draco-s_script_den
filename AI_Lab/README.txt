============================================================
PROJECT OVERVIEW: CODE AGENT SCRIPTS
============================================================

This document provides a high-level summary of the two automation scripts: 
'agent.py' and 'code_agent.py', and highlights their functional differences.

------------------------------------------------------------
1. SCRIPT: agent.py (The Technical Analyst)
------------------------------------------------------------
PURPOSE: 
An interactive, "expert-mode" virtual software engineer designed for 
deep-dive code analysis. It is optimized for C++/Qt environments.

CAPABILITIES:
- Interactive Shell: Users can engage in a continuous dialogue with the AI.
- Content Intelligence: Uses 'search_code' to find specific strings, 
  functions, or macros deep within file contents.
- Strict Security: Implements path sandboxing, read-only enforcement, 
  and file-size limits to ensure system safety.
- Expert Context: Includes a specialized system prompt to guide the AI 
  in analyzing C++, memory management, and threading.

------------------------------------------------------------
2. SCRIPT: code_agent.py (The Structural Explorer)
------------------------------------------------------------
PURPOSE: 
A lightweight, automated utility designed for navigating project 
structures and finding files via patterns.

CAPABILITIES:
- Pattern-Based Discovery: Uses glob patterns (e.g., '*.cpp') to 
  quickly locate files across the directory tree.
- Structural Navigation: Focuses on directory traversal and listing 
  contents to map out a project's hierarchy.
- Automated Reasoning: Runs as a single-shot execution; the AI 
  uses tools to gather info and then provides a final summary.

------------------------------------------------------------
3. KEY DIFFERENCES AT A GLANCE
------------------------------------------------------------

INTERACTION STYLE:
- agent.py: Interactive / Human-in-the-loop (The user asks questions).
- code_agent.py: Automated / Single-shot (The AI performs a task and exits).

SEARCH METHODOLOGY:
- agent.py: Content-Centric (Searches for text/symbols INSIDE files).
- code_agent.py: Structure-Centric (Searches for file NAMES via patterns).

INTELLECTUAL DEPTH:
- agent.py: High. It understands the nuances of code relationships 
  (.h vs .cpp) and technical debugging.
- code_agent.py: Moderate. It focuses on finding where things are 
  located within the folder tree.

USE CASE RECOMMENDATION:
- Use 'agent.py' when you need to understand HOW code works or find 
  a specific function definition.
- Use 'code_agent.py' when you need to quickly find WHERE specific 
  types of files are located within a large project.
============================================================
