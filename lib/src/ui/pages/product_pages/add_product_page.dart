import 'dart:io';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/product_controller.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/category_model/category_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/model/product_params_models/product_color.dart';
import 'package:biznex/src/core/model/product_params_models/product_info.dart';
import 'package:biznex/src/core/model/product_params_models/product_measure.dart';
import 'package:biznex/src/core/model/product_params_models/product_size.dart';
import 'package:biznex/src/providers/category_provider.dart';
import 'package:biznex/src/providers/product_color_provider.dart';
import 'package:biznex/src/providers/product_information_provider.dart';
import 'package:biznex/src/providers/product_measure_provider.dart';
import 'package:biznex/src/providers/product_size_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';

class AddProductPage extends StatefulWidget {
  final AppModel state;
  final AppColors theme;
  final void Function() onBackPressed;
  final Product? product;

  const AddProductPage({
    super.key,
    required this.state,
    required this.theme,
    required this.onBackPressed,
    this.product,
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  AppModel get state => widget.state;

  AppColors get theme => widget.theme;
  Category? _category;
  ProductMeasure? _productMeasure;
  ProductSize? _productSize;
  ProductColor? _productColor;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController percentController = TextEditingController();
  final TextEditingController resultPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController productTagnumberController = TextEditingController();
  final TextEditingController productBarcodeController = TextEditingController();
  final List<String> _imagesList = [];
  final List<ProductInfo> _productInformations = [];

  void _onConfirmPressed() async {
    if (nameController.text.trim().isEmpty) {
      ShowToast.error(context, AppLocales.productNameInputError.tr());
      return;
    }

    if (double.tryParse(resultPriceController.text.trim()) == null) {
      ShowToast.error(context, AppLocales.currentPriceInputError.tr());
      return;
    }
    Product product = Product(
      cratedDate: widget.product?.cratedDate,
      updatedDate: DateTime.now().toIso8601String(),
      id: widget.product == null ? '' : widget.product!.id,
      name: nameController.text.trim(),
      price: double.tryParse(resultPriceController.text.trim())!,
      description: _descriptionController.text.trim(),
      barcode: productBarcodeController.text.trim(),
      tagnumber: productTagnumberController.text.trim(),
      informations: _productInformations,
      images: _imagesList,
      measure: _productMeasure?.name,
      color: _productColor?.name,
      colorCode: _productColor?.code,
      size: _productSize?.name,
      amount: double.tryParse(amountController.text.trim()) ?? 1.0,
      percent: double.tryParse(percentController.text.trim()) ?? 0.0,
      category: _category,
    );

    ProductController productController = ProductController(
      context: context,
      state: state,
      onClose: widget.onBackPressed,
    );

    if (widget.product == null) {
      await productController.create(product);
    } else {
      await productController.update(product, widget.product?.id);
    }
  }

  void _initializeProductParams() {
    final Product? product = widget.product;
    if (product != null) {
      nameController.text = product.name;
      amountController.text = product.amount.toStringAsFixed(1);
      resultPriceController.text = product.price.toStringAsFixed(1);
      percentController.text = product.percent.toStringAsFixed(1);
      priceController.text = ((100 * product.price) / (100 + product.percent)).toStringAsFixed(1);
      productTagnumberController.text = product.tagnumber ?? '';
      productBarcodeController.text = product.barcode ?? '';
      _productSize = product.size == null ? null : ProductSize(name: product.size ?? '');
      _productColor = product.color == null ? null : ProductColor(name: product.color ?? '');
      _productMeasure = product.measure == null ? null : ProductMeasure(name: product.measure ?? '');
      _category = product.category;
      _descriptionController.text = product.description ?? '';
      if (product.images != null) _imagesList.addAll(product.images ?? []);
      if (product.informations != null) _productInformations.addAll(product.informations ?? []);
      setState(() {});
    }
  }

  void _onDeleteProduct() {
    if (widget.product == null) return;
    ProductController productController = ProductController(
      context: context,
      state: state,
      onClose: widget.onBackPressed,
    );
    productController.delete(widget.product?.id, c: widget.onBackPressed);
    // widget.onBackPressed();
  }

  @override
  void initState() {
    super.initState();
    _initializeProductParams();
  }

  @override
  Widget build(BuildContext context) {
    return _notDesktopScreen();
  }

  Widget _notDesktopScreen() {
    return SingleChildScrollView(
      padding: Dis.only(lr: 16, tb: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AppSimpleButton(
                icon: Icons.arrow_back_ios_new,
                onPressed: widget.onBackPressed,
                radius: 48,
                padding: 12.all,
              ),
              Text(
                AppLocales.addProductAppbarTitle.tr(),
                style: TextStyle(fontSize: 24, fontFamily: boldFamily),
              ),
            ],
          ),
          24.h,
          ..._buildMainInformationsWidget(),
          // ..._buildSecondaryInformationsWidget(),
        ],
      ),
    );
  }

  List<Widget> _buildMainInformationsWidget() {
    return [
      Container(
        padding: context.s(24).all,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppText.$18Bold("${AppLocales.productName.tr()} *"),
            8.h,
            AppTextField(
              title: AppLocales.addProductNameHint.tr(),
              controller: nameController,
              theme: theme,
              // prefixIcon: Icon(Icons.text_fields),
            ),
            24.h,
            AppText.$18Bold("${AppLocales.addProductPrice.tr()} *"),
            8.h,
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: AppTextField(
                    title: AppLocales.oldPriceHint.tr(),
                    controller: priceController,
                    theme: theme,
                    // prefixIcon: !state.isDesktop ? null : Icon(Icons.attach_money),
                    onChanged: (char) {
                      if (num.tryParse(percentController.text.trim()) != null && num.tryParse(char) != null) {
                        final percent = num.parse(percentController.text.trim());
                        final price = num.parse(char.trim());
                        resultPriceController.text = (price * (1 + (percent / 100))).toStringAsFixed(1);
                        setState(() {});
                      }
                    },
                  ),
                ),
                Expanded(
                  child: AppTextField(
                    title: AppLocales.pricePercentHint.tr(),
                    controller: percentController,
                    theme: theme,
                    // prefixIcon: !state.isDesktop ? null : Icon(Icons.percent),
                    onChanged: (char) {
                      if (num.tryParse(priceController.text.trim()) != null && num.tryParse(char) != null) {
                        final price = num.parse(priceController.text.trim());
                        final percent = num.parse(char.trim());
                        resultPriceController.text = (price * (1 + (percent / 100))).toStringAsFixed(1);
                        setState(() {});
                      }
                    },
                  ),
                ),
                Expanded(
                  child: AppTextField(
                    title: AppLocales.addProductPrice.tr(),
                    controller: resultPriceController,
                    theme: theme,
                    // prefixIcon: !state.isDesktop ? null : Icon(Icons.calculate_outlined),
                    onChanged: (char) {
                      if (num.tryParse(priceController.text.trim()) != null && num.tryParse(char) != null) {
                        final price = num.parse(priceController.text.trim());
                        final resultPrice = num.parse(char.trim());
                        percentController.text = (((resultPrice - price) * 100) / price).toStringAsFixed(1);
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
            24.h,
            AppText.$18Bold("${AppLocales.amountLabel.tr()} *"),
            8.h,
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: AppTextField(
                    title: AppLocales.amountHint.tr(),
                    controller: amountController,
                    theme: theme,
                    // prefixIcon: Icon(Icons.warehouse_outlined),
                  ),
                ),
                Expanded(
                  child: state.whenProviderData(
                    provider: productMeasureProvider,
                    builder: (measures) {
                      measures as List<ProductMeasure>;
                      return CustomPopupMenu(
                        theme: theme,
                        children: [
                          for (final item in measures)
                            CustomPopupItem(
                              title: item.name,
                              onPressed: () => setState(() => _productMeasure = item),
                            ),
                        ],
                        child: IgnorePointer(
                          ignoring: true,
                          child: AppTextField(
                            onlyRead: true,
                            title: AppLocales.measures.tr(),
                            controller: TextEditingController(text: _productMeasure?.name),
                            theme: theme,
                            // prefixIcon: Icon(Icons.scale_outlined),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            24.h,
            AppText.$18Bold("${AppLocales.addProductCategoryHint.tr()} *"),
            8.h,
            state.whenProviderData(
              provider: categoryProvider,
              builder: (measures) {
                measures as List<Category>;
                return CustomPopupMenu(
                  theme: theme,
                  children: [
                    for (final item in measures)
                      CustomPopupItem(
                        title: item.name,
                        onPressed: () => setState(() => _category = item),
                      ),
                  ],
                  child: IgnorePointer(
                    ignoring: true,
                    child: AppTextField(
                      onlyRead: true,
                      title: AppLocales.categories.tr(),
                      controller: TextEditingController(text: _category?.name),
                      theme: theme,
                      // prefixIcon: Icon(Icons.category_outlined),
                    ),
                  ),
                );
              },
            ),
            24.h,
            AppText.$18Bold(AppLocales.productImageLabel.tr()),
            8.h,
            SimpleButton(
              onPressed: () {
                FilePicker.platform.pickFiles().then((file) {
                  if (file != null && file.files.firstOrNull?.path != null) {
                    _imagesList.add(file.files.first.path!);
                    setState(() {});
                  }
                });
              },
              child: Container(
                height: 200,
                width: _imagesList.isNotEmpty ? 200 : double.infinity,
                padding: !_imagesList.isNotEmpty ? Dis.all(24) : null,
                decoration: BoxDecoration(
                  border: DashedBorder.fromBorderSide(
                    dashLength: 8,
                    side: BorderSide(color: theme.secondaryTextColor, width: 1),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(14),
                  ),
                  color: theme.scaffoldBgColor,
                  image: _imagesList.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(File(_imagesList.first)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imagesList.isEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/icons/frame.svg'),
                          Text(
                            AppLocales.uploadImage.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: mediumFamily,
                            ),
                          ),
                          Text(
                            AppLocales.supportedImageFormats.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: regularFamily,
                              color: theme.secondaryTextColor,
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () {
                            _imagesList.clear();
                            setState(() {});
                          },
                          icon: Icon(
                            Ionicons.close_circle_outline,
                            color: Colors.red,
                          ),
                        ),
                      ),
              ),
            ),
            24.h,
            AppText.$18Bold(AppLocales.productDescriptionLabel.tr()),
            8.h,
            AppTextField(
              title: AppLocales.productDescriptionHint.tr(),
              controller: _descriptionController,
              theme: theme,
              minLines: 4,
              // prefixIcon: Icon(Icons.text_fields),
            ),
            32.h,
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.product != null)
                  AppPrimaryButton(
                    theme: theme,
                    onPressed: _onDeleteProduct,
                    title: AppLocales.delete.tr(),
                    padding: Dis.only(lr: 60, tb: 16),
                    color: Colors.red,
                    border: Border.all(color: Colors.red),
                  ),
                24.w,
                AppPrimaryButton(
                  theme: theme,
                  onPressed: _onConfirmPressed,
                  title: AppLocales.add.tr(),
                  padding: Dis.only(lr: 60, tb: 16),
                ),
              ],
            ),
            32.h,
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildSecondaryInformationsWidget() {
    return [
      AppText.$18Bold(AppLocales.productImageLabel.tr()),
      8.h,
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 16,
          children: [
            for (final image in _imagesList)
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.secondaryTextColor),
                  // color: theme.accentColor,
                  image: DecorationImage(image: FileImage(File(image)), fit: BoxFit.cover),
                ),
                padding: 4.all,
                child: Align(
                  alignment: Alignment.topRight,
                  child: SimpleButton(
                    onPressed: () {
                      setState(() => _imagesList.remove(image));
                    },
                    child: Icon(
                      Ionicons.close_circle_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ),
            SimpleButton(
              onPressed: () async {
                ImagePicker imagePicker = ImagePicker();
                await imagePicker.pickImage(source: ImageSource.gallery).then((images) {
                  if (images != null) setState(() => _imagesList.add(images.path));
                });
              },
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.secondaryTextColor),
                  color: theme.accentColor,
                ),
                child: Center(
                  child: Icon(Ionicons.cloud_upload_outline),
                ),
              ),
            ),
          ],
        ),
      ),
      24.h,
      AppText.$18Bold(AppLocales.productDescriptionLabel.tr()),
      8.h,
      AppTextField(
        title: AppLocales.productDescriptionHint.tr(),
        controller: _descriptionController,
        theme: theme,
        prefixIcon: Icon(Icons.description_outlined),
      ),
      24.h,
      AppText.$18Bold(AppLocales.sizeAndColorLabel.tr()),
      8.h,
      Row(
        spacing: 16,
        children: [
          Expanded(
            child: state.whenProviderData(
              provider: productSizeProvider,
              builder: (measures) {
                measures as List<ProductSize>;
                return CustomPopupMenu(
                  theme: theme,
                  children: [
                    for (final item in measures)
                      CustomPopupItem(
                        title: item.name,
                        onPressed: () => setState(() => _productSize = item),
                      ),
                  ],
                  child: IgnorePointer(
                    ignoring: true,
                    child: AppTextField(
                      onlyRead: true,
                      title: AppLocales.productSizeHint.tr(),
                      controller: TextEditingController(text: _productSize?.name),
                      theme: theme,
                      prefixIcon: Icon(Icons.expand),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: state.whenProviderData(
              provider: productColorProvider,
              builder: (measures) {
                measures as List<ProductColor>;
                return CustomPopupMenu(
                  theme: theme,
                  children: [
                    for (final item in measures)
                      CustomPopupItem(
                        iconColor: colorFromHex(item.code!),
                        icon: Icons.circle,
                        title: item.name,
                        onPressed: () => setState(() => _productColor = item),
                      ),
                  ],
                  child: IgnorePointer(
                    ignoring: true,
                    child: AppTextField(
                      onlyRead: true,
                      title: AppLocales.productColorHint.tr(),
                      controller: TextEditingController(text: _productColor?.name),
                      theme: theme,
                      prefixIcon: Icon(
                        Icons.circle,
                        color: colorFromHex("${_productColor?.code}"),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      24.h,
      AppText.$18Bold(AppLocales.productInformation.tr()),
      8.h,
      state.whenProviderData(
        provider: productInformationProvider,
        builder: (measures) {
          measures as List<ProductInfo>;
          return CustomPopupMenu(
            theme: theme,
            children: [
              for (final item in measures)
                CustomPopupItem(
                  title: item.name,
                  onPressed: () {
                    if (_productInformations.contains(item)) {
                      _productInformations.remove(item);
                    } else {
                      _productInformations.add(item);
                    }

                    setState(() {});
                  },
                  icon: _productInformations.contains(item) ? Icons.check_box : Icons.check_box_outline_blank_sharp,
                ),
            ],
            child: IgnorePointer(
              ignoring: true,
              child: AppTextField(
                onlyRead: true,
                title: AppLocales.addProductInfoHint.tr(),
                controller: TextEditingController(text: _productInformations.map((e) => e.name).toList().join(', ')),
                theme: theme,
                prefixIcon: Icon(Icons.info_outline),
              ),
            ),
          );
        },
      ),
      24.h,
      AppText.$18Bold(AppLocales.sizeAndColorLabel.tr()),
      8.h,
      Row(
        spacing: 16,
        children: [
          Expanded(
            child: AppTextField(
              title: AppLocales.tagnumber.tr(),
              controller: productTagnumberController,
              theme: theme,
              prefixIcon: Icon(Icons.tag),
            ),
          ),
          Expanded(
            child: AppTextField(
              title: AppLocales.enterBarcode,
              controller: productBarcodeController,
              theme: theme,
              prefixIcon: Icon(Icons.barcode_reader),
            ),
          ),
        ],
      ),
      32.h,
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppPrimaryButton(
            theme: theme,
            onPressed: _onConfirmPressed,
            title: AppLocales.add.tr(),
            padding: Dis.only(lr: 48, tb: 12),
          ),
        ],
      )
    ];
  }
}
