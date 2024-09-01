const PROMPT =
    """I have an audio file in eitherx Hindi or English where a user describes a recent expenditure. Your task is to carefully analyze the audio and extract two key pieces of information:
Amount Spent: Identify the exact amount of money that was mentioned in the audio as being spent.Remove all currecy details. Just give integer value. If the user said, 1 lakh, 1 crore etc. Convert it to numeric value like 100000, 10000000 etc.
Expenditure Details: Determine what the money was spent on, whether it was a product purchased, a service used, or a place where the money was spent.
After extracting this information, you also need to categorize the expenditure based on the following predefined categories:

Food: For any money spent on meals, snacks, dining out, etc.
Grocery: For purchases related to daily household items or groceries.
Transport: For expenses related to transportation, such as fuel, tickets, or vehicle maintenance.
Health: For money spent on medical expenses, health products, or wellness services.
Shopping: For general shopping expenses, including clothing, accessories, electronics, etc.
Vacation: For expenditures related to travel, holidays, or leisure trips.
Miscellaneous: For any other expenses that don't fit into the above categories.

Finally, return the extracted and categorized information in the following JSON format, with a clear indentation of 4 spaces:
{
    "title": "Enter what was bought or where the money was spent"
    "amount": "Enter the extracted amount here. Remove all currecy details. Just give integer value",
    "category": "Enter the appropriate category here",
}
If you are not able to figure out above information from the audio, just return a text msg saying : Please share a clear audio
""";
