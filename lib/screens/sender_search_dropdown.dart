// widgets/sender_search_dropdown.dart
import 'package:flutter/material.dart';
import '../models/sender_model.dart';

class SenderSearchDropdown extends StatefulWidget {
  final List<Sender> senders;
  final Sender? selectedSender;
  final ValueChanged<Sender?> onChanged;
  final VoidCallback onAddNewSender;
  final bool isLoading;

  const SenderSearchDropdown({
    super.key,
    required this.senders,
    required this.selectedSender,
    required this.onChanged,
    required this.onAddNewSender,
    this.isLoading = false,
  });

  @override
  State<SenderSearchDropdown> createState() => _SenderSearchDropdownState();
}

class _SenderSearchDropdownState extends State<SenderSearchDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<Sender> _filteredSenders = [];
  bool _showSearchField = false;

  @override
  void initState() {
    super.initState();
    _filteredSenders = widget.senders;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant SenderSearchDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.senders != oldWidget.senders) {
      _filteredSenders = widget.senders;
      _onSearchChanged();
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredSenders = widget.senders;
      });
    } else {
      setState(() {
        _filteredSenders = widget.senders
            .where(
              (sender) =>
                  sender.name.toLowerCase().contains(query) ||
                  (sender.phone).toLowerCase().contains(query) ||
                  (sender.address).toLowerCase().contains(query),
            )
            .toList();
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearchField = !_showSearchField;
      if (!_showSearchField) {
        _searchController.clear();
        _filteredSenders = widget.senders;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showSearchField) _buildSearchField() else _buildDropdownButton(),

        if (!_showSearchField && widget.senders.isEmpty && !widget.isLoading)
          _buildEmptyState(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'افزودن فرستنده جدید',
            prefixIcon: const Icon(Icons.add),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleSearch,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        _buildSearchResults(),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredSenders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'فرستنده‌ای یافت نشد',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: widget.onAddNewSender,
                icon: const Icon(Icons.add),
                label: const Text('افزودن فرستنده جدید'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _filteredSenders.length,
        itemBuilder: (context, index) {
          final sender = _filteredSenders[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(
                sender.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            title: Text(sender.name),
            subtitle: Text(sender.phone),
            trailing: IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: () {
                widget.onChanged(sender);
                _toggleSearch();
              },
            ),
            onTap: () {
              widget.onChanged(sender);
              _toggleSearch();
            },
          );
        },
      ),
    );
  }

  Widget _buildDropdownButton() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButton<Sender>(
                value: widget.selectedSender,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text('فرستنده را انتخاب کنید'),
                items: [
                  if (widget.selectedSender != null)
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        'بدون انتخاب',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ...widget.senders.map((sender) {
                    return DropdownMenuItem(
                      value: sender,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              sender.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sender.name),
                                Text(
                                  sender.phone,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _toggleSearch,
          tooltip: 'جستجوی فرستنده',
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: widget.onAddNewSender,
          tooltip: 'افزودن فرستنده جدید',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'هیچ فرستنده‌ای ثبت نشده است',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: widget.onAddNewSender,
              icon: const Icon(Icons.add),
              label: const Text('افزودن فرستنده جدید'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
