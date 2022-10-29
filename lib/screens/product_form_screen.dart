import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});
  static const routeName = '/product-form';

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _imageUrlController = TextEditingController();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  var _isInit = true;
  var _editedProduct = ProductModel(
    id: null,
    title: '',
    description: '',
    imageUrl: '',
    price: 0,
    isFavorite: false,
  );
  var _isLoading = false;

  void _updateImage() {
    if (!_imageFocus.hasFocus) {
      setState(() {});
    }
  }

  @override
  void initState() {
    _imageFocus.addListener(_updateImage);
    super.initState();
  }

  @override
  void dispose() {
    _imageFocus.removeListener(_updateImage);
    _imageUrlController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId);

        _imageUrlController.text = _editedProduct.imageUrl;
        _titleController.text = _editedProduct.title;
        _priceController.text = _editedProduct.price.toString();
        _descriptionController.text = _editedProduct.description;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_editedProduct.id as String, _editedProduct)
          .catchError((error) {
        return showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('An error occured!'),
            content: const Text('Something went wrong...'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('cancel')),
            ],
          ),
        );
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    } else {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('An error occured!'),
            content: const Text('Something went wrong...'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('cancel')),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Form'),
        actions: [
          IconButton(
            onPressed: _isLoading ? () {} : _saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? const Text('ImageURL')
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(width: 10),
                          // -------------------------------------------------------------
                          Expanded(
                            child: TextFormField(
                              onSaved: (newValue) {
                                _editedProduct = ProductModel(
                                  id: _editedProduct.id,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  imageUrl: newValue.toString(),
                                  price: _editedProduct.price,
                                  isFavorite: _editedProduct.isFavorite,
                                );
                              },
                              focusNode: _imageFocus,
                              controller: _imageUrlController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter an url';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Enter a valid url';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                label: Text('ImageURL'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // -------------------------------------------------------------
                      TextFormField(
                        onSaved: (newValue) {
                          _editedProduct = ProductModel(
                            id: _editedProduct.id,
                            title: newValue.toString(),
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                        controller: _titleController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter a Title';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          label: Text('Title'),
                        ),
                      ),
                      // -------------------------------------------------------------
                      TextFormField(
                        onSaved: (newValue) {
                          _editedProduct = ProductModel(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            price: double.parse(newValue.toString()),
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                        controller: _priceController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter an Amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter an Amount';
                          }
                          if (double.parse(value) <= 1) {
                            return 'Enter a valid Amount';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          label: Text('Amount'),
                        ),
                      ),
                      // -------------------------------------------------------------
                      TextFormField(
                        onSaved: (newValue) {
                          _editedProduct = ProductModel(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: newValue.toString(),
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                        controller: _descriptionController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter a Description';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.newline,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          label: Text('Description'),
                        ),
                      ),
                      // -------------------------------------------------------------
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
