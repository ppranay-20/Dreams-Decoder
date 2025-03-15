Map<DateTime, List<dynamic>> groupChatsByDate(List<dynamic> chats) {
  Map<DateTime, List<dynamic>> groupedEvents = {};

  for (var chat in chats) {
    final rawDate = chat['chat_open'];
    DateTime parsedDate = DateTime.parse(rawDate);
    DateTime normalizedDate =
        DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

    if (groupedEvents.containsKey(normalizedDate)) {
      groupedEvents[normalizedDate]!.add(chat);
    } else {
      groupedEvents[normalizedDate] = [chat];
    }
  }

  return groupedEvents;
}
