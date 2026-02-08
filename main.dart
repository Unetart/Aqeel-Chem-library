import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

void main() => runApp(const ChemicalInventoryApp());

class ChemicalInventoryApp extends StatelessWidget {
  const ChemicalInventoryApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICSA - Chemical Inventory',
      debugShowCheckedModeBanner: false, // Removes the debug banner in top-right corner
      theme: ThemeData(
          useMaterial3: true, // Using the latest Material Design 3
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 55, 255, 155))), // Custom green color theme
      home: const InventoryScreen(), // Starting screen of our app
    );
  }
}

// Model class - represents a single chemical item in inventory
// Think of this as a blueprint for what data each chemical should have
class ChemicalItem {
  final String id, name, symbol, category;
  final SDS sds; // Safety Data Sheet information
  
  ChemicalItem({
      required this.id,
      required this.name,
      required this.symbol,
      required this.category,
      required this.sds});
}

// SDS Model - holds all safety information about a chemical
// SDS = Safety Data Sheet (important for lab safety!)
class SDS {
  final String handling, spillResponse, hazards, firstAid, storage, url;
  
  SDS({
      required this.handling,
      required this.spillResponse,
      this.hazards = '', // Optional fields have default empty values
      this.firstAid = '',
      this.storage = '',
      this.url = ''});
}

// State management class brain of app
// stores chemicals and tells the UI when data changes
class InventoryStore extends ChangeNotifier {
  // Private list to storechemical items
  final List<ChemicalItem> _items = [];
  
  // Constructor runs when create a new InventoryStore
  InventoryStore() {
    _loadSamples(); // Load some sample data when app starts
  }

  // Load sample chemicals so have data to work with
  void _loadSamples() {
    // Adding Hydrochloric Acid
    addItem(ChemicalItem(
        id: 'CHEM001',
        name: 'Hydrochloric Acid',
        symbol: 'HCl',
        category: 'Acid',
        sds: SDS(
            handling: 'Wear gloves, goggles, lab coat. Ventilated area.',
            spillResponse:
                'Neutralize with sodium bicarbonate. Absorb with inert material.',
            hazards: 'Corrosive, severe burns. Harmful if inhaled.',
            firstAid: 'Eye: Rinse 15min. Skin: Wash with soap/water.',
            storage: 'Corrosive-resistant container, cool/dry.',
            url:
                'https://sds.chemicalsafety.com/sds/pda/msds/getpdf.ashx?action=msdsdocument&auth=200C200C200C200C2008207A200D2078200C200C200C200C200C200C200C200C200C2008&param1=ZmRwLjJfMzk4NDAwMDNORQ==&unique=1770325572&session=ef445adfbbfeafaad45b7df6a3fa4574&hostname=45.134.79.159')));

    // Adding Sodium Hydroxide
    addItem(ChemicalItem(
        id: 'CHEM002',
        name: 'Sodium Hydroxide',
        symbol: 'NaOH',
        category: 'Base',
        sds: SDS(
            handling: 'Avoid skin/eye contact. Use PPE.',
            spillResponse:
                'Neutralize with dilute acid. Clean with absorbent.',
            hazards: 'Corrosive, severe burns.',
            firstAid: 'Flush 15+ minutes.',
            storage: 'Closed container, away from acids.',
            url:
                'https://sds.chemicalsafety.com/sds/pda/msds/getpdf.ashx?action=msdsdocument&auth=200C200C200C200C2008207A200D2078200C200C200C200C200C200C200C200C200C2008&param1=ZmRwLjFfNjk3Nzg1MDNORQ==&unique=1770325681&session=ef445adfbbfeafaad45b7df6a3fa4574&hostname=45.134.79.159')));

    // Adding Ethanol
    addItem(ChemicalItem(
        id: 'CHEM003',
        name: 'Ethanol',
        symbol: 'C2H5OH',
        category: 'Solvent',
        sds: SDS(
            handling: 'Keep from heat/flames. Ventilated area.',
            spillResponse: 'Absorb with sand. Avoid ignition.',
            hazards: 'Highly flammable. Eye/respiratory irritant.',
            firstAid: 'If inhaled, fresh air.',
            storage: 'Flammable cabinet, away from oxidizers.',
            url:
                'https://sds.chemicalsafety.com/sds/pda/msds/getpdf.ashx?action=msdsdocument&auth=200C200C200C200C2008207A200D2078200C200C200C200C200C200C200C200C200C2008&param1=ZmRwLjJfNTM5ODY5MzNORQ==&unique=1770325712&session=ef445adfbbfeafaad45b7df6a3fa4574&hostname=45.134.79.159')));
  }

  // Getter to access the list of items (read-only access)
  List<ChemicalItem> get items => _items;
  
  // Add a new chemical to inventory
  void addItem(ChemicalItem item) {
    _items.add(item);
    notifyListeners(); // Tell all listeners that data changed!
  }

  // Remove a chemical by its ID
  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners(); // Update the UI
  }

  // Search function - filters chemicals based on search query
  List<ChemicalItem> search(String query) {
    if (query.isEmpty) return _items; // If no search, show everything
    
    final q = query.toLowerCase(); // Convert to lowercase for case-insensitive search
    return _items
        .where((item) =>
            item.name.toLowerCase().contains(q) ||
            item.symbol.toLowerCase().contains(q) ||
            item.category.toLowerCase().contains(q) ||
            item.id.toLowerCase().contains(q))
        .toList();
  }

  // Get list of all unique categories
  List<String> get categories =>
      _items.map((e) => e.category).toSet().toList()..sort();
  
  // Filter chemicals by a specific category
  List<ChemicalItem> filterByCategory(String category) =>
      _items.where((item) => item.category == category).toList();
  
  // Find a specific chemical by ID
  ChemicalItem? getById(String id) {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null; // Return null if not found
    }
  }
}

// Global instance of our inventory store - accessible throughout the app
final inventoryStore = InventoryStore();

// Main inventory screen - shows the list of all chemicals
// StatefulWidget because we need to track search query and filters
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String query = ''; // Current search query
  String? selectedCategory; // Currently selected category filter (null = show all)

  @override
  Widget build(BuildContext context) {
    // Get filtered results based on category or search
    final results = selectedCategory != null
        ? inventoryStore.filterByCategory(selectedCategory!)
        : inventoryStore.search(query);
    
    return Scaffold(
      // Top app bar with title and icon
      appBar: AppBar(
          title: const Row(children: [
        Icon(Icons.science, size: 28),
        SizedBox(width: 8),
        Text('Chemical Inventory')
      ])),
      
      // Floating button to add new chemicals
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            // Navigate to add chemical screen
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddChemicalScreen()));
            setState(() {}); // Refresh the list when user come back
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add')),
      
      // Main body with search, filters, and chemical list
      body: Column(children: [
        _buildSearchBar(),
        _buildCategoryFilters(),
        Expanded(
            child: results.isEmpty
                ? _buildEmptyState() // Show empty state if no results
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: results.length,
                    itemBuilder: (context, i) =>
                        _buildChemicalCard(results[i]))) // Build each chemical card
      ]),
    );
  }

  // Search bar widget at the top
  Widget _buildSearchBar() => Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
          decoration: InputDecoration(
              hintText: 'Search for chemicals...',
              prefixIcon: const Icon(Icons.search), // Magnifying glass icon
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => query = '')) // Clear button
                  : null,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true),
          onChanged: (value) => setState(() {
                query = value; // Update search query
                selectedCategory = null; // Clear category filter when searching
              })));

  // Horizontal scrolling category filter chips
  Widget _buildCategoryFilters() => SizedBox(
      height: 40,
      child: ListView(
          scrollDirection: Axis.horizontal, // Scroll horizontally
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            _buildChip('All', null), // "All" chip to clear filters
            ...inventoryStore.categories
                .map((cat) => _buildChip(_getIcon(cat), cat)) // One chip per category
          ]));

  // Individual filter chip widget
  Widget _buildChip(String label, String? category) {
    final isSelected = selectedCategory == category;
    return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
            label: Text(label),
            selected: isSelected, // Highlight if selected
            onSelected: (_) => setState(() {
                  selectedCategory = category; // Update selected category
                  query = ''; // Clear search when filtering by category
                })));
  }

  // Get icon label for each category (no emojis)
  String _getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'acid':
        return 'Acid';
      case 'base':
        return 'Base';
      case 'solvent':
        return 'Solvent';
      case 'salt':
        return 'Salt';
      default:
        return category;
    }
  }

  // Individual chemical card in the list
  Widget _buildChemicalCard(ChemicalItem item) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
          // Circular avatar with chemical symbol
          leading: CircleAvatar(
              backgroundColor: _getColor(item.category),
              child: Text(
                  item.symbol.length > 3
                      ? item.symbol.substring(0, 3) // Truncate if too long
                      : item.symbol,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
          
          // Chemical name as title
          title: Text(item.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          
          // Category and ID as subtitle
          subtitle: Text('${item.category} • ID: ${item.id}'),
          
          // QR code button
          trailing: IconButton(
              icon: const Icon(Icons.qr_code_2),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => QRCodeScreen(item: item)))),
          
          // Tap to view SDS details
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => SDSScreen(item: item)))));

  // Empty state when no chemicals found
  Widget _buildEmptyState() => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.science_outlined, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        Text(query.isEmpty ? 'No chemicals yet' : 'No results',
            style: const TextStyle(fontSize: 18, color: Colors.grey))
      ]));

  // Get color based on chemical category
  Color _getColor(String category) {
    switch (category.toLowerCase()) {
      case 'acid':
        return Colors.red;
      case 'base':
        return Colors.blue;
      case 'solvent':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }
}

// Screen for adding a new chemical to inventory
class AddChemicalScreen extends StatefulWidget {
  const AddChemicalScreen({super.key});
  
  @override
  State<AddChemicalScreen> createState() => _AddChemicalScreenState();
}

class _AddChemicalScreenState extends State<AddChemicalScreen> {
  // Form key for validation
  final _form = GlobalKey<FormState>();
  
  // Text controllers for all input fields
  final _name = TextEditingController(),
      _symbol = TextEditingController(),
      _category = TextEditingController(),
      _handling = TextEditingController(),
      _spill = TextEditingController(),
      _hazards = TextEditingController(),
      _firstAid = TextEditingController(),
      _storage = TextEditingController(),
      _url = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Add Chemical')),
      body: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            // Basic chemical information
            _field(_name, 'Name', 'e.g., Sulfuric Acid', true),
            _field(_symbol, 'Symbol', 'e.g., H2SO4', true),
            _field(_category, 'Category', 'e.g., Acid, Base', true),
            
            const Divider(height: 32),
            
            // Safety data section
            const Text('Safety Data Sheet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Safety information fields
            _field(_handling, 'Handling', 'Safety procedures...', true, 3),
            _field(_spill, 'Spill Response', 'Emergency steps...', true, 3),
            _field(_hazards, 'Hazards', 'Known hazards...', false, 2),
            _field(_firstAid, 'First Aid', 'Treatment...', false, 2),
            _field(_storage, 'Storage', 'Storage conditions...', false, 2),
            _field(_url, 'SDS URL',
                'https://www.chemicalsafety.com/sds-search', false, 1),
            
            const SizedBox(height: 24),
            
            // Save button
            ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Chemical'),
                style:
                    ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)))
          ])));

  // Helper method to create text input fields
  Widget _field(TextEditingController ctrl, String label, String hint, bool req,
          [int lines = 1]) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
              controller: ctrl,
              maxLines: lines, // Number of lines for multiline fields
              decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true),
              // Validation - required fields must not be empty
              validator:
                  req ? (v) => v?.isEmpty ?? true ? 'Required' : null : null));

  // Save the new chemical to inventory
  void _save() {
    // Check if form is valid
    if (!_form.currentState!.validate()) return;
    
    // Generate unique ID based on current timestamp
    final id = 'CHEM${DateTime.now().millisecondsSinceEpoch % 100000}';
    
    // Create and add new chemical item
    inventoryStore.addItem(ChemicalItem(
        id: id,
        name: _name.text,
        symbol: _symbol.text,
        category: _category.text,
        sds: SDS(
            handling: _handling.text,
            spillResponse: _spill.text,
            hazards: _hazards.text,
            firstAid: _firstAid.text,
            storage: _storage.text,
            url: _url.text)));
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_name.text} added'), backgroundColor: Colors.green));
    
    // Go back to main screen
    Navigator.pop(context);
  }
}

// QR Code screen - displays a QR code for the chemical
// used tutor from: https://www.youtube.com/watch?v=vdRCbg2FQ2M from Hussain Mustafa - adapted to fit the app
class QRCodeScreen extends StatelessWidget {
  final ChemicalItem item;
  const QRCodeScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('QR Code'), actions: [
        // Share button (placeholder functionality)
        IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality'))))
      ]),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Placeholder QR code card
        Card(
            elevation: 4,
            child: Container(
                width: 250,
                height: 250,
                color: Colors.grey[200],
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2, size: 120, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      const Text('Please insert an SDS URL in order to have a QR Code',
                          style: TextStyle(color: Colors.grey))
                    ]))),
        
        const SizedBox(height: 24),
        
        // Chemical name and symbol
        Text(item.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(item.symbol,
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
        
        const SizedBox(height: 16),
        
        // Info card with ID and category
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _info('ID', item.id),
              const SizedBox(height: 8),
              _info('Category', item.category)
            ])),
        
        const SizedBox(height: 24),
        
        // Button to view full SDS
        ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => SDSScreen(item: item))),
            icon: const Icon(Icons.description),
            label: const Text('View SDS'))
      ])));

  // Helper to display info rows
  Widget _info(String label, String value) => Row(children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(child: Text(value))
      ]);
}

// Safety Data Sheet screen - shows all safety information for a chemical
class SDSScreen extends StatelessWidget {
  final ChemicalItem item;
  const SDSScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text('${item.name} SDS'), actions: [
        // Quick access to QR code from SDS screen
        IconButton(
            icon: const Icon(Icons.qr_code_2),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => QRCodeScreen(item: item))))
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        header(), // Chemical info header
        const SizedBox(height: 16),
        
        // Button to view full SDS document online
        if (item.sds.url.isNotEmpty) sdsButton(context),
        
        // Required safety sections
        _section('Handling', item.sds.handling, Icons.pan_tool, Colors.blue),
        _section('Spill Response', item.sds.spillResponse, Icons.warning,
            Colors.orange),
        
        // Optional sections (only shown if data exists)
        if (item.sds.hazards.isNotEmpty)
          _section('Hazards', item.sds.hazards, Icons.dangerous, Colors.red),
        if (item.sds.firstAid.isNotEmpty)
          _section('First Aid', item.sds.firstAid, Icons.health_and_safety,
              Colors.green),
        if (item.sds.storage.isNotEmpty)
          _section('Storage', item.sds.storage, Icons.inventory, Colors.purple),
        
       
      ]));

  // Button to view full SDS document
  // Source: https://www.youtube.com/watch?v=cSR34CNXLvo from Heyflutter.com - adapted to fit the app
  Widget sdsButton(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Link(
      target: LinkTarget.self, // Open in same tab
      uri: Uri.parse(item.sds.url),
      builder: (context, followLink) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[50],
          foregroundColor: Colors.blue[900],
          elevation: 2,
          padding: EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: followLink, // Open the link when button is pressed
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Icon(Icons.web, color: Colors.blue[700], size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Click here to View Full SDS Document',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900])),
                  const SizedBox(height: 4),
                  const Text('Online safety data sheet',
                      style: TextStyle(fontSize: 12, color: Colors.grey))
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.blue[700])
          ]),
        ),
      ),
    ),
  );

  // Header card with chemical basic info
  Widget header() => Card(
      color: Colors.teal[50],
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            // Chemical symbol in circle
            CircleAvatar(
                radius: 30,
                backgroundColor: Colors.teal,
                child: Text(
                    item.symbol.length > 4
                        ? item.symbol.substring(0, 4)
                        : item.symbol,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(width: 16),
            
            // Name, ID, and category
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('ID ${item.id}',
                      style: const TextStyle(color: Colors.grey)),
                  Text('Category ${item.category}',
                      style: const TextStyle(color: Colors.grey))
                ]))
          ])));

  //  safety information section
  Widget _section(String title, String content, IconData icon, Color color) =>
      Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header with icon
                    Row(children: [
                      Icon(icon, color: color),
                      const SizedBox(width: 12),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold))
                    ]),
                    const SizedBox(height: 8),
                    // Section content
                    Text(content,
                        style: const TextStyle(fontSize: 14, height: 1.5))
                  ])));
}