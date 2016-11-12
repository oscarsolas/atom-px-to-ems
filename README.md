# px-to-em package

DESCRIPTION
-----------

You can turn 'px' to 'em' or 'rem' units Instantly.
The default base is 16px but you can define a custom base for each conversion



USAGE
-----

First method:

1 - Type cmd+shift+E on the line to be converted.


Second method:

1 - Add the base value to the end of line. Example:

	 margin: 18px; /12


2 - Type cmd+shift+E and the result is:

	 margin: 1.5em;  /* 18/12 */



*Both methods accept multiline conversion



AVAILABLE OPTIONS
-----------------

- Unit selection: you can select em or rem
- Default Base: you can define a custom base (default is 16px)
- Comments: you can enable or disable the comment at end of converted line
- Fallback: you have the posibility of maintain the original line and adds the conversion to the bottom line.
