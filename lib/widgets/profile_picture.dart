import 'package:flutter/material.dart';
import 'package:project/pages/full_image_view.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onUpload;

  const ProfilePictureWidget({
    super.key,
    required this.imageUrl,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: imageUrl.isNotEmpty
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullImageView(imageUrl: imageUrl),
                ),
              );
            }
          : null,
      child: Hero(
        tag: imageUrl,
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          child: imageUrl.isEmpty
              ? const CircularProgressIndicator()
              : ClipOval(
                  child: Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
