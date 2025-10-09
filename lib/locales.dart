class AppLocales {
  static const Map<String, Map<String, String>> translations = {
    'en': {
      'email_label': 'Email',
      'password_label': 'Password',
      'login_button': 'Login',
      'forgot_password': 'Forgot Password?',
      'sign_up': 'Sign-up',
      'field_required': 'This field is required',
      'incorrect_credentials': 'Incorrect credentials.',
      'login_success': 'Login successful!',
      'news_feed': 'News Feed',
      'what_new': 'What\'s new?',
      'new_post': '1 new post',
      'new_posts': '{count} new posts',
      'share_post': 'Share this post',
      'write_something': 'Write something...',
      'share': 'Share',
      'share_success': 'Post shared successfully!',
      'share_error': 'Error while sharing.',
      'share_empty': 'No content entered to share.',
      'network_error': 'Network error: {error}',
      'profile': 'Profile',
      'settings': 'Settings',
      'theme': 'Theme',
      'choose_theme': 'Choose a theme',
      'system_theme': 'Use system theme',
      'light_mode': 'Light Mode',
      'dark_mode': 'Dark Mode',
      'close': 'Close',
      'language': 'Language',
      'choose_language': 'Choose Language',
      'edit': 'Edit',
      'delete': 'Delete',
      'user_info': 'User Info',
      'actuality': 'Actuality',
      'project': 'Project',
      'notifications': 'Notifications',
      'shop': 'Shop',
      'messages': 'Messages',
      'oops': 'Oops', // Ajout pour ActualityDetails (titre)
      'add_comment': 'Add a comment...', // Ajout pour placeholder
      'send': 'Send', // Ajout pour bouton
      'comment_success':
          'Comment added successfully!', // Ajout pour message de succès
      'comment_error': 'Error: {error}', // Ajout pour message d’erreur

      'what_s_new': 'What\'s new?',

      'no_content': 'No content entered to share',

      'post_published_success': 'Your post has been published successfully!',
      'saved_as_draft': 'Saved as draft',
      'draft': 'Draft',
      'publish': 'Publish',
      'create_post_title': 'Create a post',

      'sending': 'Sending...',
      'post': 'Post',
      'reply_to': 'Reply to',
      'scroll_to_hide': 'Scroll to Hide BottomBar',
      'item': 'Item',

// Général disease_prediction
      'disease_prediction_title': 'Disease Prediction',
      'more_info': 'More Info',
      'advice': 'Advice',
      'treatment_advice': 'Treatment Advice',
      'analyzing': 'Analyzing...',
      'prediction_result_title': 'Prediction Result',
      'predicted_disease': 'Predicted Disease',
      'capture_image': 'Capture an Image',
      'model_not_loaded': 'The model is not yet loaded. Please wait.',
      'no_image_captured': 'No image captured.',
      'image_capture_error': 'Error capturing image',
      'prediction_result': 'Prediction',
      'prediction_error': 'Prediction error',
      'invalid_image_error': 'Invalid or corrupted image',
      'image_preprocessing_error': 'Image preprocessing error',

      // Conseils
      'advice_pepper_bacterial_spot':
          'Use a suitable bactericide fungicide, such as copper-based products. Practice crop rotation and avoid overhead irrigation.',
      'advice_pepper_healthy':
          'Maintain a healthy environment by monitoring humidity and fertilization. Continue practicing crop rotation.',
      'advice_potato_early_blight':
          'Use fungicides like mancozeb to control early blight. Monitor planting density and humidity.',
      'advice_potato_late_blight':
          'Apply systemic fungicides like chlorothalonil. Ensure good crop ventilation and adequate spacing.',
      'advice_potato_healthy':
          'Continue to maintain optimal growing conditions with proper irrigation and nutrient management.',
      'advice_tomato_bacterial_spot':
          'Apply a copper-based fungicide and remove infected leaves. Avoid overhead irrigation to limit spread.',
      'advice_tomato_early_blight':
          'Use fungicides like chlorothalonil or azoxystrobin at the first signs. Water at the base of plants to avoid wetting leaves.',
      'advice_tomato_late_blight':
          'Use fungicides like copper. Be mindful of humidity and ensure proper plant spacing.',
      'advice_tomato_leaf_mold':
          'Apply fungicides like tebuconazole or azoxystrobin. Ensure good ventilation and humidity control.',
      'advice_tomato_septoria_leaf_spot':
          'Use fungicides like chlorothalonil. Avoid excessive moisture and remove affected leaves.',
      'advice_tomato_spider_mites':
          'Apply acaricides or horticultural oils to treat mites. Monitor humidity and reduce high temperatures.',
      'advice_tomato_target_spot':
          'Use a fungicide for blight and ensure proper plant spacing. Remove affected leaves promptly.',
      'advice_tomato_yellow_leaf_curl_virus':
          'There is no cure. Remove infected plants and control insect vectors like thrips.',
      'advice_tomato_mosaic_virus':
          'There is no treatment. Remove infected plants and disinfect tools. Use resistant varieties.',
      'advice_tomato_healthy':
          'Maintain good crop management with balanced fertilization, disease control, and proper ventilation.',
      'advice_default': 'Consult an expert for further advice.',

      // Détails sur la maladie
      'symptoms': 'Symptoms',
      'details': 'Details',

      // Conseils de traitement
      'treatment_advice_title': 'Treatment Advice',
      'recommended_products': 'Recommended Products',

      // Général Pest Prediction
      'pest_prediction_title': 'Pest Prediction',
      'pest_model_loaded': 'Pest model loaded successfully!',
      'pest_model_error': 'Error loading pest model',
      'learn_more': 'Learn More',
      'link_error': 'Unable to open the link',

      // Conseils
      'advice_ants':
          'Ants can be controlled with poisoned baits or diatomaceous earth.',
      'advice_bees':
          'Bees are essential pollinators. Avoid killing them and use gentle deterrent methods.',
      'advice_beetle':
          'Beetles can be controlled with specific insecticides or traps.',
      'advice_caterpillar':
          'Caterpillars can be removed manually or with biological insecticides.',
      'advice_earthworms':
          'Earthworms are beneficial for the soil. No action needed.',
      'advice_earwig':
          'Earwigs can be controlled with cardboard traps or insecticides.',
      'advice_grasshopper':
          'Grasshoppers can be controlled with insecticides or physical barriers.',
      'advice_moth':
          'Moths can be controlled with pheromone traps or insecticides.',
      'advice_slug': 'Slugs can be eliminated with beer traps or slug pellets.',
      'advice_snail':
          'Snails can be controlled with snail pellets or physical barriers.',
      'advice_wasp':
          'Wasps can be managed with wasp traps or insecticide sprays.',
      'advice_weevil':
          'Weevils can be controlled with specific insecticides or traps.',

      'create_project': 'Create a Project', // Ajout pour AddProject
      'project_name': 'Project Name', // Ajout pour AddProject
      'description': 'Describe your project', // Ajout pour AddProject
      'sowing_date': 'Sowing Date', // Ajout pour AddProject
      'end_date': 'End Date', // Ajout pour AddProject
      'crop_type': 'Crop Type', // Ajout pour AddProject
      'crop_variety': 'Crop Variety', // Ajout pour AddProject
      'land_area': 'Land Area', // Ajout pour AddProject
      'base_price': 'Base Price', // Ajout pour AddProject
      'select_collaborators': 'Select Collaborators', // Ajout pour AddProject
      'add': 'Add', // Ajout pour AddProject
      'create': 'Create', // Ajout pour AddProject
      'project_created_success':
          'Your project has been successfully added', // Ajout pour AddProject
      'error': 'Error', // Ajout pour AddProject
      'project_creation_error':
          'Error creating project: {error}', // Ajout pour AddProject
      'select_crop_type': 'Please select a crop type', // Ajout pour AddProject
      'select_crop_variety':
          'Please select a crop variety', // Ajout pour AddProject
      'ok': 'OK', // Ajout pour AddProject
      'dashboard': 'Dashboard', // Ajout pour ProjetctDetails
      'crop_progress': 'Crop Progress', // Ajout pour ProjetctDetails
      'collaboration_tools':
          'Collaboration Tools', // Ajout pour ProjetctDetails
      'ai_alerts': 'AI Alerts', // Ajout pour ProjetctDetails
      'market_place': 'Market Place', // Ajout pour ProjetctDetails
      'start_date': 'Start Date', // Ajout pour ProjetctDetails
      'description_label': 'Description', // Ajout pour ProjetctDetails
      'team_members': 'Team Members', // Ajout pour ProjetctDetails
      'no_members':
          'There are no members for this project.', // Ajout pour ProjetctDetails
      'add_to_marketplace': 'Add to Marketplace', // Ajout pour ProjetctDetails
      'add_to_marketplace_success': 'Add to marketplace succesfully',
      'project_not_mature':
          'Your project is not yet mature', // Ajout pour ProjetctDetails
      'already_in_marketplace':
          'This project is already in the Marketplace', // Ajout pour ProjetctDetails
      'confirmation': 'Confirmation', // Ajout pour ProjetctDetails
      'confirm_add_marketplace':
          'Are you sure you want to add your project to the marketplace?', // Ajout pour ProjetctDetails
      'cancel': 'Cancel', // Ajout pour ProjetctDetails
      'confirm': 'Confirm', // Ajout pour ProjetctDetails
      'marketplace_success':
          'Project successfully added to the Marketplace', // Ajout pour ProjetctDetails
      'marketplace_error':
          'Error adding project to the Marketplace: {error}', // Ajout pour ProjetctDetails

      'projects': 'Projects',
      'my_projects': 'My Projects',
      'collaboration': 'Collaboration',
      'choose_project_type': 'Choose Project Type',
      'what_to_add': 'What do you want to add?',
      'agricultural_project': 'Agricultural Project',
      'agricultural_transformation_project':
          'Agricultural Transformation Project',
      'collaborations_in_progress': 'Collaborations in Progress',
      'no_collaborations_available': 'No collaborations available.',
      'project_deleted_success': 'Your project has been successfully deleted',
      'crop_label': 'Crop: ',

      'create_profile': 'Create Profile',
      'username': 'Username',
      'bio': 'Bio',
      'location': 'Location',
      'date_of_birth': 'Date of Birth',
      'required_field': 'Required field',
      'select_date': 'Select a date',
      'create_profile_button': 'Create Profile',
      'profile_created_success': 'Profile created successfully!',
      'profile_creation_error': 'Error creating profile: {error}',

      'edit_profile': 'Edit Profile',
      'save': 'Save',
      'profile_updated_success': 'Profile updated successfully!',
      'update_profile_error': 'Error updating profile: {error}',

      'following': 'Following',
      'followers': 'Followers',
      'posts': 'Posts',
      'media': 'Media',
      'likes': 'Likes',
      'no_posts': 'No posts',
      'no_media': 'No media',
      'no_likes': 'No likes',
      'content_unavailable': 'Content unavailable',
      'unknown_name': 'Unknown name',

      'what_to_do': 'What do you want to do?',
      'diseases': 'Diseases',
      'pests': 'Pests',
      'fertilizers': 'Fertilizers',
      'friends_enemies': 'Friends/Enemies',

      'collaboration_tool': 'Collaboration Tool',
      'collaborative_tools': 'Collaborative Tools',
      'task_management': 'Task Management',
      'track_assign_tasks': 'Track and assign tasks',
      'team_chat': 'Team Chat',
      'real_time_communication': 'Real-time communication',
      'shared_notes': 'Shared Notes',
      'collaborate_notes': 'Collaborate on notes',
      'team_memberships': 'Team Memberships',
      'manage_team_memberships': 'Manage team memberships',

      'days_count': 'Number of days',
      'maturity_level': 'Maturity level',
      'germination': 'Germination',
      'growth': 'Growth',
      'maturation': 'Maturation',
      'harvest': 'Harvest',
      'not_started': 'Not started',
      'crop_variety_unavailable': 'Crop variety information unavailable',

      'marketplace_view': 'Marketplace View',
      'crop': 'Crop',
      'variety': 'Variety',
      'potential_buyers': 'Potential Buyers',
      'quantity': 'Quantity',
      'distance': 'Distance',
      'contacting': 'Contacting',

      'memberships': 'Memberships',
      'add_member': 'Add Member',
      'select_user': 'Select User',
      'select_role': 'Select Role',
      'validate': 'Validate',
      'refresh_members_error': 'Error refreshing members',
      'select_user_required': 'Please select a user',
      'select_role_required': 'Please select a role',
      'name_unavailable': 'Name unavailable',
      'role_unavailable': 'Role unavailable',
      'role': 'Role',

      'chat': 'Chat',
      'type_message': 'Type your message...',

      'create_task': 'Create Task',
      'title': 'Title',
      'priority': 'Priority',
      'important': 'Important',
      'very_important': 'Very Important',
      'select_member': 'Select a Member',
      'status': 'Status',
      'no_name_available': 'No Name Available',

      'tasks': 'Tasks',
      'search_task': 'Search a task',

      'add_product_title': 'Add a Product',
      'select_project_required': 'Please select a project',
      'describe_product': 'Describe your product',
      'add_button': 'Add',
      'product_added_success': 'Product added successfully!',
      'no_token_found': 'No token found!',
      'user_connection_error': 'Error connecting user: {error}',
      'no_user_connected': 'No user connected',
      'user_id_null': 'User ID is null',
      'invalid_user_id': 'Invalid user ID: {userId}',
      'response_not_list': 'Response is not a list of projects: {response}',
      'fetch_projects_error': 'Error fetching user projects: {error}',
      'project_not_selected': 'Project not selected',
      'invalid_project_or_description':
          'Invalid project ID or public description',
      'add_product_error': 'Error adding product: {error}',

      'exchange_messages': 'Exchange Messages',
      'enter_message': 'Enter your message...',
      'message_sent': 'Message sent',
      'days_before_maturity': 'Days before maturity',
      'days': 'days',
      'available_quantity': 'Available quantity',

      'debug_model_loaded': 'Pest model loaded successfully!',
      'debug_model_error': 'Error loading pest model: {error}',
      'debug_no_token': 'No token found!',
      'debug_user_connected': 'User connected: {user}',
      'debug_user_connection_error': 'Error connecting user: {error}',
      'debug_products_loaded': 'Products loaded successfully!',
      'debug_products_error': 'Error loading products: {error}',
      'debug_invalid_product': 'Invalid product: {product}',
      'debug_image_captured': 'Image captured: {path}',
      'debug_no_image_captured': 'No image captured.',
      'debug_image_capture_error': 'Error capturing image: {error}',
      'debug_prediction_error': 'Prediction error: {error}',
      'debug_invalid_image': 'Invalid or corrupted image.',
      'debug_image_preprocessing_error': 'Image preprocessing error: {error}',

      'products': 'Products',
      'needs': 'Needs',
      'search_product': 'Search for a product...',
      'maturity': 'Maturity: {days} days',
      'mature': 'Mature',
      'available': 'Available',
      'days_left': '{days} days left',
      'units': '{quantity} units',

      'missing_id_error': 'Profile ID or User ID is missing.',
      'debug_cover_profile_photos':
          'Cover Photo: {cover}, Profile Photo: {profile}',

      'unknown_username': 'Unknown Username',
      'unknown_bio': 'Unknown Bio',

      'debug_posts_fetched': 'Fetched {count} posts',
      'debug_fetch_posts_error': 'Error fetching posts: {error}',

      'crop_comparison_title': 'Comparison for {crop}',
      'associations': 'Associations',
      'compare': 'Compare',
      'load_crops_error': 'Error loading crops. Please try again.',
      'crop_not_found': 'Crop not found!',
      'best_associations': 'Best Associations',
      'worst_associations': 'Worst Associations',
      'best_association': 'Best association',
      'worst_association': 'Worst association',
      'reason': 'Reason',
      'select_crop': 'Select a crop',
      'comparison_result': 'Comparison result',

      // Enhanced reasons
      'highly_similar_nutrients':
          'Highly similar nutrient needs optimize soil use.',
      'highly_different_nutrients':
          'Highly different nutrient needs may deplete soil unevenly.',
      'nitrogen_complementarity':
          'One crop fixes nitrogen, benefiting the other’s high nitrogen needs.',
      'highly_similar_ph':
          'Very close soil pH requirements ensure optimal growth.',
      'highly_different_ph':
          'Significantly different soil pH needs hinder compatibility.',
      'highly_similar_temperature':
          'Very similar temperature needs ensure synchronized growth.',
      'highly_different_temperature':
          'Widely different temperature needs disrupt growth cycles.',
      'highly_similar_humidity':
          'Very similar humidity needs support mutual thriving.',
      'highly_different_humidity':
          'Significantly different humidity needs cause stress.',
      'highly_similar_water':
          'Very similar water needs ensure efficient irrigation.',
      'highly_different_water':
          'Widely different water needs complicate irrigation.',
      'highly_similar_soil': 'Identical soil type enhances compatibility.',
      'different_soil': 'Different soil types reduce compatibility.',
      'strong_pest_resistance':
          'Both have strong pest resistance, reducing risks.',
      'different_pest_resistance':
          'Varying pest resistance increases vulnerability.',
      'highly_similar_growth':
          'Nearly identical growth durations align harvest times.',
      'highly_different_growth':
          'Widely different growth durations misalign cycles.',
      'complementary_growth':
          'Complementary growth durations allow succession planting.',
      'allelopathy_effect':
          'One crop’s allelopathic effects may inhibit the other.',
      'nitrogen_water_conflict':
          'Nitrogen fixation conflicts with high water needs.',
      // Debugging
      'debug_tts_error': 'TTS error: {error}',
      'debug_load_crops_error': 'Error loading crops: {error}',

      // New keys
      'disease_description': 'Disease Description',
      'chemical_treatments': 'Chemical Treatments',
      'biological_treatments': 'Biological Treatments',
      'cultural_practices': 'Cultural Practices',
      'prevention': 'Prevention',
      'bacterial_spot_pepper': 'Bacterial Spot (Pepper)',
      'bacterial_spot_pepper_desc':
          'Caused by *Xanthomonas campestris pv. vesicatoria*, this bacterial disease leads to water-soaked spots that turn dark brown with yellow halos, reducing yield.',
      'early_blight_potato': 'Early Blight (Potato)',
      'early_blight_potato_desc':
          'Caused by *Alternaria solani*, this fungal disease produces concentric rings on leaves, thriving in warm, wet conditions.',
      'late_blight_potato': 'Late Blight (Potato)',
      'late_blight_potato_desc':
          'Caused by *Phytophthora infestans*, a devastating oomycete disease with rapid spread in cool, moist conditions, causing dark lesions and tuber rot.',
      'bacterial_spot_tomato': 'Bacterial Spot (Tomato)',
      'bacterial_spot_tomato_desc':
          'Caused by *Xanthomonas spp.*, this disease creates small, greasy spots with yellow halos, often worsened by overhead irrigation.',
      'late_blight_tomato': 'Late Blight (Tomato)',
      'late_blight_tomato_desc':
          'Caused by *Phytophthora infestans*, this oomycete disease causes large, irregular lesions with white sporulation in humid conditions.',
      'unknown_disease': 'Unknown Disease',
      'unknown_disease_desc':
          'No specific information available for this disease.',
      'no_treatment_available':
          'No specific treatments available for this disease.',
      'consult_expert': 'Consult an agricultural expert for tailored advice.',
      'general_prevention':
          'Use certified seeds, monitor weather conditions, and maintain good field hygiene.',

      'pathogen': 'Pathogen',
      'conditions': 'Favorable Conditions',
      'no_data': 'No data available.',
      'no_symptoms': 'No symptoms available.',
      'unknown_pathogen': 'Unknown',
      'unknown_conditions': 'Unknown',

      'healthy_pepper': 'Healthy Pepper',
      'healthy_pepper_desc':
          'Healthy bell peppers exhibit no signs of disease and grow vigorously.',

      'healthy_potato': 'Healthy Potato',
      'healthy_potato_desc':
          'Healthy potatoes show no disease symptoms and thrive under proper care.',

      'early_blight_tomato': 'Early Blight (Tomato)',
      'early_blight_tomato_desc':
          'A common fungal disease impacting tomato foliage and yield.',

      'leaf_mold_tomato': 'Leaf Mold (Tomato)',
      'leaf_mold_tomato_desc':
          'A fungal disease thriving in humid environments, affecting tomato leaves.',
      'septoria_leaf_spot_tomato': 'Septoria Leaf Spot (Tomato)',
      'septoria_leaf_spot_tomato_desc':
          'A fungal disease causing significant leaf loss in tomatoes.',
      'spider_mites_tomato': 'Spider Mites (Tomato)',
      'spider_mites_tomato_desc':
          'A pest infestation causing stippling and reduced vigor in tomatoes.',
      'target_spot_tomato': 'Target Spot (Tomato)',
      'target_spot_tomato_desc':
          'A fungal disease affecting tomato leaves, stems, and fruits.',
      'yellow_leaf_curl_tomato': 'Yellow Leaf Curl Virus (Tomato)',
      'yellow_leaf_curl_tomato_desc':
          'A viral disease transmitted by whiteflies, stunting tomato plants.',
      'mosaic_virus_tomato': 'Mosaic Virus (Tomato)',
      'mosaic_virus_tomato_desc':
          'A viral disease causing mottling and deformation in tomatoes.',
      'healthy_tomato': 'Healthy Tomato',
      'healthy_tomato_desc':
          'Healthy tomatoes exhibit no disease symptoms and optimal growth.',

      'disease_details_title': 'Details for {disease}',

      'capture_camera': 'Camera',
      'capture_gallery': 'Gallery',
      'no_prediction': 'No prediction made yet.',
      'processing_image': 'Processing image...',
      'model_loaded': 'Disease model for {cropName} loaded successfully.',
      'model_error': 'Error loading model: {error}',
      'no_model_available': 'No model available for {cropName}.',

      'low_confidence':
          'Prediction confidence too low ({confidence}%). Try another image.',
      'prediction_history': 'Prediction History',

      'advice_pepper__bell___bacterial_spot':
          'Use copper-based bactericides and improve air circulation.',
      'advice_potato___early_blight':
          'Apply protective fungicides like Mancozeb and rotate crops.',
      'advice_potato___late_blight':
          'Use systemic fungicides (e.g., Metalaxyl) and remove infected plants.',

      'advice_tomato_spider_mites_two_spotted_spider_mite':
          'Apply miticides (e.g., Abamectin) and increase humidity.',
      'advice_tomato__target_spot': 'Use Mancozeb and reduce leaf wetness.',
      'advice_tomato__tomato_yellowleaf__curl_virus':
          'Control whiteflies with Imidacloprid and use resistant varieties.',
      'advice_tomato__tomato_mosaic_virus':
          'Disinfect tools and use certified seeds.',

      'confirm_deletion': 'Comfirm deletion',
      'are_you_sure_delete': 'Are you sure you want to delete?',
      'yes': 'Yes',
      'no': 'No',
      'Deconnexion': 'Logout',

      // TreatmentAdviceScreen
      'components': 'Components',
      'application': 'Application',
      'precaution': 'Precaution',
      'prepare': 'Prepare',
      'per_liter': 'per liter',

      // RecipePreparationPage
      'recipe_preparation_title': 'Preparing {treatment}',
      'step': 'Step',
      'pause': 'Pause',
      'resume': 'Resume',
      'next': 'Next',
      'preparation_complete': 'Preparation complete!',
      'treatment_not_found': 'Treatment {treatment} not found.',

      'settings_options': 'Settings options',
      'general_settings': 'General Settings',
      'marketplace_notifications': 'Marketplace Notifications',
      'project_notifications': 'Project Notifications',
      'notify_project_start': 'Project Start',
      'notify_progress_50': '50% Progress',
      'notify_progress_80': '80% Progress',
      'notify_harvest': 'Harvest Reminder',

      'notification_settings': 'Notification Settings',
      'manage_notifications': 'Manage Notifications',
      'notify_availability': 'Product Availability Soon',
      'notify_message_sent': 'Message Sent Confirmation',
      'notify_low_stock': 'Low Stock Alert',
      'notify_maturity': 'Product Maturity Reached',
      'harvest_days_before': 'Days before harvest',

      'just_now': 'Just now',
      'hours_ago': '{hours} hours ago',
      'yesterday': 'Yesterday',
      'days_ago': '{days} days ago',
      'weeks_ago': '{weeks} weeks ago',
      'new': 'New',

      'report': 'Report',
      'report_submitted': 'Report submitted!',
      'logout': 'Logout',

      'follow': 'Follow',
      'unfollow': 'Unfollow',
      'message': 'Message',

      'share_profile': 'Share Profile',
      'profile_shared': 'Profile shared!',

      'germinating': '{days} days left',
      'growing': '{days} days left',
      'maturing': '{days} days left',
      'debug_maturity_status':
          'Product: {product}, Phase: {phase}, Days Until Maturity: {daysUntilMaturity}, Grace Period: {gracePeriodDays}, Visible: {isVisible}',
      'buy_now': 'Buy now',

      'not_visible_marketplace': 'No longer visible due to expiration',

      'pending': 'Pending',

      'no_pending_requests': 'No pending requests',

      'request_cancelled': 'Request cancelled successfully',

      'edit_post_title': 'Edit Post',
      'image': 'Image',
      'confirm_delete': 'Confirm Delete',
      'delete_post_message':
          'Are you sure you want to delete this post? This action cannot be undone.',
      'comments': 'Comments',

      'marketplace_listings': 'Marketplace Listings',
      'no_listings': 'No listings available',
      'invalid_quantity': 'Invalid quantity',
      'marketplace_stats': 'Marketplace Statistics',
      'statut': 'Status',
      'publications': 'Publications',
      'quantity_published': 'Quantity Published',
      'pourcentage_published': 'Percentage Published',
      'unit': 'unit',
      'select_quantity': 'Choose amount',
      'remaining_quantity_with_units': 'Remaining quantity: {quantity} units',

      'contact_all_buyers': 'Contact All Buyers',
      'filter_options': 'Filter Options',
      'sort_by_quantity': 'Sort by Quantity',
      'sort_by_date': 'Sort by Date',
      'sort_by_distance': 'Sort by Distance',

      'project_media': "Project Media",
      'add_photo': "Add Photo",
      'photo_added': "Photo added successfully",
      'publish_to_news': "Publish to News",
      'annotate': "Annotate", // Ou "Label" selon l'usage
      'media_deleted': "Media deleted",
      'media_details': "Media Details",
      'published_to_news': "Published in News",

      'add_media_action': "Add Media (+)",
      'open_camera': "Take Photo",
      'open_gallery': "Choose from Gallery",
      'media_added_success': "✓ Media added successfully",
    },
    'fr': {
      'email_label': 'Email',
      'password_label': 'Mot de passe',
      'login_button': 'Connexion',
      'forgot_password': 'Mot de passe oublié ?',
      'sign_up': 'S’inscrire',
      'field_required': 'Ce champ est requis',
      'incorrect_credentials': 'Identifiants incorrects.',
      'login_success': 'Connexion réussie !',
      'news_feed': 'Fil d\'actualité',
      'what_new': 'Quoi de neuf ?',
      'new_post': '1 nouveau post',
      'new_posts': '{count} nouveaux posts',
      'share_post': 'Partager ce post',
      'write_something': 'Écrivez quelque chose...',
      'share': 'Partager',
      'share_success': 'Post partagé avec succès !',
      'share_error': 'Erreur lors du partage.',
      'share_empty': 'Aucun contenu saisi pour partager.',
      'network_error': 'Erreur réseau : {error}',
      'profile': 'Profil',
      'settings': 'Paramètres',
      'theme': 'Thème',
      'choose_theme': 'Choisir un thème',
      'system_theme': 'Utiliser le thème du système',
      'light_mode': 'Mode clair',
      'dark_mode': 'Mode sombre',
      'close': 'Fermer',
      'language': 'Langage',
      'choose_language': 'Choisir une langue',
      'edit': 'Éditer',
      'delete': 'Supprimer',
      'user_info': 'Infos Utilisateur',
      'actuality': 'Actualité',
      'project': 'Projet',
      'notifications': 'Notifications',
      'shop': 'Boutique',
      'messages': 'Messages',
      'oops': 'Oops', // Ajout pour ActualityDetails (titre)
      'add_comment': 'Ajouter un commentaire...', // Ajout pour placeholder
      'send': 'Envoyer', // Ajout pour bouton
      'comment_success':
          'Commentaire ajouté avec succès !', // Ajout pour message de succès
      'comment_error': 'Erreur : {error}', // Ajout pour message d’erreur

      'what_s_new': 'Quoi de neuf ?',

      'no_content': 'Aucun contenu saisi pour partager',

      'post_published_success': 'Votre post a été publié avec succès !',
      'saved_as_draft': 'Enregistré en brouillon',
      'draft': 'Brouillon',
      'publish': 'Publier',
      'create_post_title': 'Créer un post',

      'sending': 'Envoi en cours...',
      'post': 'Poster',
      'reply_to': 'Répondre à',
      'scroll_to_hide': 'Faites défiler pour masquer la barre',
      'item': 'Élément',

// Général disease Prediction
      'disease_prediction_title': 'Prediction des Maladies',
      'more_info': 'Plus d\'Info',
      'advice': 'Conseil',
      'treatment_advice': 'Conseils de Traitement',
      'analyzing': 'Analyse en cours...',
      'prediction_result_title': 'Résultat de la Prédiction',
      'predicted_disease': 'Maladie Prédite',
      'capture_image': 'Capturer une Image',
      'model_not_loaded':
          'Le modèle n\'est pas encore chargé. Veuillez patienter.',
      'no_image_captured': 'Aucune image capturée.',
      'image_capture_error': 'Erreur lors de la capture de l\'image',
      'prediction_result': 'Prédiction',
      'prediction_error': 'Erreur de prédiction',
      'invalid_image_error': 'Image invalide ou corrompue',
      'image_preprocessing_error': 'Erreur de prétraitement de l\'image',

      // Conseils
      'advice_pepper_bacterial_spot':
          'Utilisez un fongicide bactéricide adapté, comme ceux à base de cuivre. Pratiquez la rotation des cultures et évitez l\'irrigation par aspersion.',
      'advice_pepper_healthy':
          'Maintenez un environnement sain en surveillant l\'humidité et la fertilisation. Continuez à pratiquer la rotation des cultures.',
      'advice_potato_early_blight':
          'Utilisez des fongicides comme le mancozèbe pour contrôler le mildiou précoce. Surveillez la densité de plantation et l\'humidité.',
      'advice_potato_late_blight':
          'Appliquez des fongicides systémiques comme le chlorothalonil. Assurez-vous d’une bonne aération des cultures et d\'un espacement adéquat.',
      'advice_potato_healthy':
          'Continuez à maintenir des conditions de culture optimales avec une irrigation adéquate et une gestion des nutriments.',
      'advice_tomato_bacterial_spot':
          'Appliquez un fongicide à base de cuivre et enlevez les feuilles infectées. Évitez d\'irriguer par aspersion pour limiter la propagation.',
      'advice_tomato_early_blight':
          'Utilisez des fongicides comme le chlorothalonil ou l\'azoxystrobine dès l’apparition des symptômes. Arrosez à la base des plantes pour éviter l\'humidité sur les feuilles.',
      'advice_tomato_late_blight':
          'Utilisez des fongicides comme le cuivre. Faites attention à l\'humidité et espacez bien les plants.',
      'advice_tomato_leaf_mold':
          'Appliquez un fongicide comme le tébuconazole ou l’azoxystrobine. Assurez-vous d’une bonne aération et d’un contrôle de l’humidité.',
      'advice_tomato_septoria_leaf_spot':
          'Utilisez des fongicides comme le chlorothalonil. Évitez l\'humidité excessive et retirez les feuilles affectées.',
      'advice_tomato_spider_mites':
          'Appliquez des acaricides ou des huiles horticoles pour traiter les acariens. Surveillez l\'humidité et réduisez les températures élevées.',
      'advice_tomato_target_spot':
          'Utilisez un fongicide contre le mildiou et espacez bien les plantes. Retirez les feuilles affectées rapidement.',
      'advice_tomato_yellow_leaf_curl_virus':
          'Il n\'existe pas de traitement curatif. Éliminez les plantes infectées et contrôlez les insectes vecteurs comme les thrips.',
      'advice_tomato_mosaic_virus':
          'Il n\'y a pas de traitement contre ce virus. Éliminez les plantes infectées et désinfectez les outils. Utilisez des variétés résistantes.',
      'advice_tomato_healthy':
          'Maintenez une bonne gestion des cultures avec une fertilisation équilibrée, un contrôle des maladies et une bonne aération.',
      'advice_default':
          'Consultez un expert pour des conseils supplémentaires.',

      // Détails sur la maladie
      'symptoms': 'Symptômes',
      'details': 'Détails',

      // Conseils de traitement
      'treatment_advice_title': 'Conseils de Traitement',
      'recommended_products': 'Produits Recommandés',

      // Général Prest predi
      'pest_prediction_title': 'Prédiction des Parasites',
      'pest_model_loaded': 'Modèle de parasites chargé avec succès !',
      'pest_model_error': 'Erreur lors du chargement du modèle de parasites',
      'learn_more': 'En savoir plus',
      'link_error': 'Impossible d\'ouvrir le lien',

      // Conseils
      'advice_ants':
          'Les fourmis peuvent être contrôlées avec des appâts empoisonnés ou de la terre de diatomée.',
      'advice_bees':
          'Les abeilles sont des pollinisateurs essentiels. Évitez de les tuer et utilisez des méthodes de dissuasion douces.',
      'advice_beetle':
          'Les coléoptères peuvent être contrôlés avec des insecticides spécifiques ou des pièges.',
      'advice_caterpillar':
          'Les chenilles peuvent être éliminées manuellement ou avec des insecticides biologiques.',
      'advice_earthworms':
          'Les vers de terre sont bénéfiques pour le sol. Aucune action nécessaire.',
      'advice_earwig':
          'Les perce-oreilles peuvent être contrôlés avec des pièges à base de carton ou des insecticides.',
      'advice_grasshopper':
          'Les sauterelles peuvent être contrôlées avec des insecticides ou des barrières physiques.',
      'advice_moth':
          'Les mites peuvent être contrôlées avec des pièges à phéromones ou des insecticides.',
      'advice_slug':
          'Les limaces peuvent être éliminées avec des pièges à bière ou des granulés anti-limaces.',
      'advice_snail':
          'Les escargots peuvent être contrôlés avec des granulés anti-escargots ou des barrières physiques.',
      'advice_wasp':
          'Les guêpes peuvent être gérées avec des pièges à guêpes ou des pulvérisations insecticides.',
      'advice_weevil':
          'Les charançons peuvent être contrôlés avec des insecticides spécifiques ou des pièges.',

      'create_project': 'Créer un Projet', // Ajout pour AddProject
      'project_name': 'Nom du projet', // Ajout pour AddProject
      'description': 'Décrivez votre projet', // Ajout pour AddProject
      'sowing_date': 'Date de semi', // Ajout pour AddProject
      'end_date': 'Date de fin', // Ajout pour AddProject
      'crop_type': 'Type de culture', // Ajout pour AddProject
      'crop_variety': 'Variété de culture', // Ajout pour AddProject
      'land_area': 'Superficie du terrain', // Ajout pour AddProject
      'base_price': 'Prix de base', // Ajout pour AddProject
      'select_collaborators':
          'Sélectionnez des collaborateurs', // Ajout pour AddProject
      'add': 'Ajouter', // Ajout pour AddProject
      'create': 'Créer', // Ajout pour AddProject
      'project_created_success':
          'Votre projet a bien été ajouté', // Ajout pour AddProject
      'error': 'Erreur', // Ajout pour AddProject
      'project_creation_error':
          'Erreur lors de la création du projet : {error}', // Ajout pour AddProject
      'select_crop_type':
          'Veuillez sélectionner un type de culture', // Ajout pour AddProject
      'select_crop_variety':
          'Veuillez sélectionner une variété de culture', // Ajout pour AddProject
      'ok': 'OK', // Ajout pour AddProject

      'dashboard': 'Tableau de bord', // Ajout pour ProjetctDetails
      'crop_progress': 'Progrès de la culture', // Ajout pour ProjetctDetails
      'collaboration_tools':
          'Outils de collaboration', // Ajout pour ProjetctDetails
      'ai_alerts': 'Alertes IA', // Ajout pour ProjetctDetails
      'market_place': 'Place de marché', // Ajout pour ProjetctDetails
      'start_date': 'Date de début', // Ajout pour ProjetctDetails
      'description_label': 'Description', // Ajout pour ProjetctDetails
      'team_members': 'Membres de l\'équipe', // Ajout pour ProjetctDetails
      'no_members':
          'Il n\'y a aucun membre pour ce projet.', // Ajout pour ProjetctDetails
      'add_to_marketplace':
          'Ajouter à la place de marché', // Ajout pour ProjetctDetails
      'add_to_marketplace_success': 'Ajout à place de marché reussi',
      'project_not_mature':
          'Votre projet n\'est pas encore mature', // Ajout pour ProjetctDetails
      'already_in_marketplace':
          'Ce projet est déjà dans la place de marché', // Ajout pour ProjetctDetails
      'confirmation': 'Confirmation', // Ajout pour ProjetctDetails
      'confirm_add_marketplace':
          'Êtes-vous sûr de vouloir ajouter votre projet à la place de marché ?', // Ajout pour ProjetctDetails
      'cancel': 'Annuler', // Ajout pour ProjetctDetails
      'confirm': 'Valider', // Ajout pour ProjetctDetails
      'marketplace_success':
          'Projet ajouté à la place de marché avec succès', // Ajout pour ProjetctDetails
      'marketplace_error':
          'Erreur lors de l\'ajout du projet à la place de marché : {error}', // Ajout pour ProjetctDetails

      'projects': 'Projets',
      'my_projects': 'Mes Projets',
      'collaboration': 'Collaboration',
      'choose_project_type': 'Choisissez le type de projet',
      'what_to_add': 'Que voulez-vous ajouter ?',
      'agricultural_project': 'Projet Agricole',
      'agricultural_transformation_project':
          'Projet de Transformation Agricole',
      'collaborations_in_progress': 'Collaborations en cours',
      'no_collaborations_available': 'Aucune collaboration disponible.',
      'project_deleted_success': 'Votre projet a bien été supprimé',
      'crop_label': 'Culture : ',

      'create_profile': 'Créer un Profil',
      'username': 'Nom d\'utilisateur',
      'bio': 'Bio',
      'location': 'Emplacement',
      'date_of_birth': 'Date de naissance',
      'required_field': 'Champ obligatoire',
      'select_date': 'Sélectionnez une date',
      'create_profile_button': 'Créer le Profil',
      'profile_created_success': 'Profil créé avec succès !',
      'profile_creation_error':
          'Erreur lors de la création du profil : {error}',

      'edit_profile': 'Modifier le profil',
      'save': 'Enregistrer',
      'profile_updated_success': 'Profil mis à jour avec succès !',
      'update_profile_error':
          'Erreur lors de la mise à jour du profil : {error}',

      'following': 'Abonnements',
      'followers': 'Abonnés',
      'posts': 'Publications',
      'media': 'Médias',
      'likes': 'Likes',
      'no_posts': 'Aucune publication',
      'no_media': 'Aucun média',
      'no_likes': 'Aucun like',
      'content_unavailable': 'Contenu indisponible',
      'unknown_name': 'Nom inconnu',

      'what_to_do': 'Que voulez-vous faire ?',
      'diseases': 'Maladies',
      'pests': 'Parasites',
      'fertilizers': 'Fertilisants',
      'friends_enemies': 'Amies/Ennemies',

      'collaboration_tool': 'Outil de Collaboration',
      'collaborative_tools': 'Outils Collaboratifs',
      'task_management': 'Gestion des Tâches',
      'track_assign_tasks': 'Suivre et assigner des tâches',
      'team_chat': 'Chat d\'Équipe',
      'real_time_communication': 'Communication en temps réel',
      'shared_notes': 'Notes Partagées',
      'collaborate_notes': 'Collaborer sur des notes',
      'team_memberships': 'Membres de l\'Équipe',
      'manage_team_memberships': 'Gérer les membres de l\'équipe',

      'days_count': 'Nombre de jours',
      'maturity_level': 'Niveau de maturité',
      'germination': 'Germination',
      'growth': 'Croissance',
      'maturation': 'Maturation',
      'harvest': 'Récolte',
      'not_started': 'Non commencé',
      'crop_variety_unavailable':
          'Informations sur la variété de culture non disponibles',

      'marketplace_view': 'Vue du Marché',
      'crop': 'Culture',
      'variety': 'Variété',
      'potential_buyers': 'Acheteurs Potentiels',
      'quantity': 'Quantité',
      'distance': 'Distance',
      'contacting': 'Contact en cours avec',

      'memberships': 'Membres',
      'add_member': 'Ajouter un membre',
      'select_user': 'Sélectionner un utilisateur',
      'select_role': 'Sélectionner un rôle',
      'validate': 'Valider',
      'refresh_members_error': 'Erreur lors du rafraîchissement des membres',
      'select_user_required': 'Veuillez sélectionner un utilisateur',
      'select_role_required': 'Veuillez sélectionner un rôle',
      'name_unavailable': 'Nom non disponible',
      'role_unavailable': 'Rôle non disponible',
      'role': 'Rôle',

      'chat': 'Chat',
      'type_message': 'Tapez votre message...',

      'create_task': 'Créer une Tâche',
      'title': 'Titre',
      'priority': 'Priorité',
      'important': 'Importante',
      'very_important': 'Très Importante',
      'select_member': 'Sélectionnez un membre',
      'status': 'Statut',
      'no_name_available': 'Nom non disponible',

      'tasks': 'Tâches',
      'search_task': 'Rechercher une tâche',

      'add_product_title': 'Ajouter un produit',
      'select_project_required': 'Veuillez sélectionner un projet',
      'describe_product': 'Décrivez votre produit',
      'add_button': 'Ajouter',
      'product_added_success': 'Produit ajouté avec succès !',
      'no_token_found': 'Aucun token trouvé !',
      'user_connection_error':
          'Erreur lors de la connexion de l\'utilisateur : {error}',
      'no_user_connected': 'Aucun utilisateur connecté',
      'user_id_null': 'ID utilisateur est null',
      'invalid_user_id': 'ID utilisateur invalide : {userId}',
      'response_not_list':
          'La réponse n\'est pas une liste de projets : {response}',
      'fetch_projects_error':
          'Erreur lors de la récupération des projets de l\'utilisateur : {error}',
      'project_not_selected': 'Projet non sélectionné',
      'invalid_project_or_description':
          'ID du projet ou description publique invalide',
      'add_product_error': 'Erreur lors de l\'ajout du produit : {error}',

      'exchange_messages': 'Échanger des messages',
      'enter_message': 'Entrez votre message...',
      'message_sent': 'Message envoyé',
      'days_before_maturity': 'Jours avant maturité',
      'days': 'jours',
      'available_quantity': 'Quantité disponible',

      'debug_model_loaded': 'Modèle de parasites chargé avec succès !',
      'debug_model_error':
          'Erreur lors du chargement du modèle de parasites : {error}',
      'debug_no_token': 'Aucun token trouvé !',
      'debug_user_connected': 'Utilisateur connecté : {user}',
      'debug_user_connection_error':
          'Erreur lors de la connexion de l\'utilisateur : {error}',
      'debug_products_loaded': 'Produits chargés avec succès !',
      'debug_products_error':
          'Erreur lors du chargement des produits : {error}',
      'debug_invalid_product': 'Produit invalide : {product}',
      'debug_image_captured': 'Image capturée : {path}',
      'debug_no_image_captured': 'Aucune image capturée.',
      'debug_image_capture_error':
          'Erreur lors de la capture de l\'image : {error}',
      'debug_prediction_error': 'Erreur de prédiction : {error}',
      'debug_invalid_image': 'Image invalide ou corrompue.',
      'debug_image_preprocessing_error':
          'Erreur de prétraitement de l\'image : {error}',

      'products': 'Produits',
      'needs': 'Besoins',
      'search_product': 'Rechercher un produit...',
      'maturity': 'Maturité : {days} jours',
      'mature': 'Mature',
      'available': 'Disponible',
      'days_left': '{days} jours restants',
      'units': '{quantity} unités',

      'missing_id_error': 'L’ID du profil ou de l’utilisateur est manquant.',
      'debug_cover_profile_photos':
          'Photo de couverture : {cover}, Photo de profil : {profile}',

      'unknown_username': 'Nom d’utilisateur inconnu',
      'unknown_bio': 'Bio inconnue',

      'debug_posts_fetched': '{count} publications récupérées',
      'debug_fetch_posts_error':
          'Erreur lors de la récupération des publications : {error}',

// Existing keys (partial list)
      'crop_comparison_title': 'Comparaison pour {crop}',
      'associations': 'Associations',
      'compare': 'Comparer',
      'load_crops_error':
          'Erreur lors du chargement des cultures. Veuillez réessayer.',
      'crop_not_found': 'Culture introuvable !',
      'best_associations': 'Meilleures associations',
      'worst_associations': 'Pires associations',
      'best_association': 'Meilleure association',
      'worst_association': 'Pire association',
      'reason': 'Raison',
      'select_crop': 'Sélectionnez une culture',
      'comparison_result': 'Résultat de la comparaison',
      // Enhanced reasons
      'highly_similar_nutrients':
          'Besoins en nutriments très similaires optimisent l’utilisation du sol.',
      'highly_different_nutrients':
          'Besoins en nutriments très différents épuisent le sol inégalement.',
      'nitrogen_complementarity':
          'Une culture fixe l’azote, profitant aux besoins élevés de l’autre.',
      'highly_similar_ph':
          'Exigences de pH très proches assurent une croissance optimale.',
      'highly_different_ph':
          'Besoins de pH très différents nuisent à la compatibilité.',
      'highly_similar_temperature':
          'Besoins en température très similaires synchronisent la croissance.',
      'highly_different_temperature':
          'Besoins en température très différents désynchronisent les cycles.',
      'highly_similar_humidity':
          'Besoins en humidité très similaires favorisent une croissance mutuelle.',
      'highly_different_humidity':
          'Besoins en humidité très différents causent du stress.',
      'highly_similar_water':
          'Besoins en eau très similaires optimisent l’irrigation.',
      'highly_different_water':
          'Besoins en eau très différents compliquent l’irrigation.',
      'highly_similar_soil': 'Type de sol identique renforce la compatibilité.',
      'different_soil': 'Types de sol différents réduisent la compatibilité.',
      'strong_pest_resistance':
          'Résistance élevée aux ravageurs réduit les risques.',
      'different_pest_resistance':
          'Résistance variable aux ravageurs augmente la vulnérabilité.',
      'highly_similar_growth':
          'Durées de croissance presque identiques alignent les récoltes.',
      'highly_different_growth':
          'Durées de croissance très différentes désalignent les cycles.',
      'complementary_growth':
          'Durées de croissance complémentaires permettent une plantation en succession.',
      'allelopathy_effect':
          'Effets allelopathiques d’une culture peuvent inhiber l’autre.',
      'nitrogen_water_conflict':
          'Fixation d’azote entre en conflit avec des besoins élevés en eau.',
      // Debugging
      'debug_tts_error': 'Erreur TTS : {error}',
      'debug_load_crops_error':
          'Erreur lors du chargement des cultures : {error}',

      // New keys
      'disease_description': 'Description de la maladie',
      'chemical_treatments': 'Traitements chimiques',
      'biological_treatments': 'Traitements biologiques',
      'cultural_practices': 'Pratiques culturales',
      'prevention': 'Prévention',
      'bacterial_spot_pepper': 'Tache bactérienne (Poivron)',
      'bacterial_spot_pepper_desc':
          'Causée par *Xanthomonas campestris pv. vesicatoria*, cette maladie bactérienne provoque des taches imbibées d’eau qui brunissent avec des halos jaunes, réduisant le rendement.',
      'early_blight_potato': 'Mildiou précoce (Pomme de terre)',
      'early_blight_potato_desc':
          'Causée par *Alternaria solani*, cette maladie fongique produit des anneaux concentriques sur les feuilles, favorisée par des conditions chaudes et humides.',
      'late_blight_potato': 'Mildiou tardif (Pomme de terre)',
      'late_blight_potato_desc':
          'Causée par *Phytophthora infestans*, cette maladie oomycète dévastatrice se propage rapidement dans des conditions fraîches et humides, provoquant des lésions noires et la pourriture des tubercules.',
      'bacterial_spot_tomato': 'Tache bactérienne (Tomate)',
      'bacterial_spot_tomato_desc':
          'Causée par *Xanthomonas spp.*, cette maladie crée des petites taches huileuses avec des halos jaunes, aggravée par l’irrigation par aspersion.',
      'late_blight_tomato': 'Mildiou tardif (Tomate)',
      'late_blight_tomato_desc':
          'Causée par *Phytophthora infestans*, cette maladie oomycète provoque de grandes lésions irrégulières avec une sporulation blanche dans des conditions humides.',
      'unknown_disease': 'Maladie inconnue',
      'unknown_disease_desc':
          'Aucune information spécifique disponible pour cette maladie.',
      'no_treatment_available':
          'Aucun traitement spécifique disponible pour cette maladie.',
      'consult_expert':
          'Consultez un expert agricole pour des conseils adaptés.',
      'general_prevention':
          'Utilisez des semences certifiées, surveillez les conditions météorologiques et maintenez une bonne hygiène des champs.',

      'capture_camera': 'Caméra',
      'capture_gallery': 'Galerie',
      'processing_image': 'Traitement de l’image...',

      'low_confidence':
          'Confiance de prédiction trop faible ({confidence}%). Essayez une autre image.',
      'prediction_history': 'Historique des prédictions',

      'pathogen': 'Pathogène',
      'conditions': 'Conditions favorables',
      'no_data': 'Aucune donnée disponible.',
      'no_symptoms': 'Aucun symptôme disponible.',
      'unknown_pathogen': 'Inconnu',
      'unknown_conditions': 'Inconnu',

      'healthy_pepper': 'Poivron sain',
      'healthy_pepper_desc':
          'Les poivrons sains ne présentent aucun signe de maladie et croissent vigoureusement.',

      'healthy_potato': 'Pomme de terre saine',
      'healthy_potato_desc':
          'Les pommes de terre saines ne montrent aucun symptôme de maladie et prospèrent avec des soins appropriés.',

      'early_blight_tomato': 'Mildiou précoce (Tomate)',
      'early_blight_tomato_desc':
          'Une maladie fongique courante affectant le feuillage et le rendement des tomates.',
      'leaf_mold_tomato': 'Moisissure des feuilles (Tomate)',
      'leaf_mold_tomato_desc':
          'Une maladie fongique prospérant dans les environnements humides, affectant les feuilles de tomates.',
      'septoria_leaf_spot_tomato': 'Tache septorienne (Tomate)',
      'septoria_leaf_spot_tomato_desc':
          'Une maladie fongique causant une perte significative de feuilles chez les tomates.',
      'spider_mites_tomato': 'Acariens (Tomate)',
      'spider_mites_tomato_desc':
          'Une infestation de ravageurs causant des ponctuations et une vigueur réduite chez les tomates.',
      'target_spot_tomato': 'Tache cible (Tomate)',
      'target_spot_tomato_desc':
          'Une maladie fongique affectant les feuilles, tiges et fruits des tomates.',
      'yellow_leaf_curl_tomato':
          'Virus de l’enroulement des feuilles jaunes (Tomate)',
      'yellow_leaf_curl_tomato_desc':
          'Une maladie virale transmise par les aleurodes, freinant la croissance des tomates.',
      'mosaic_virus_tomato': 'Virus de la mosaïque (Tomate)',
      'mosaic_virus_tomato_desc':
          'Une maladie virale causant des marbrures et des déformations chez les tomates.',
      'healthy_tomato': 'Tomate saine',
      'healthy_tomato_desc':
          'Les tomates saines ne présentent aucun symptôme de maladie et une croissance optimale.',

      'disease_details_title': 'Détails pour {disease}',
      'no_prediction': 'Aucune prédiction effectuée pour le moment.',
      'model_loaded': 'Modèle de maladie pour {cropName} chargé avec succès.',
      'model_error': 'Erreur lors du chargement du modèle : {error}',
      'no_model_available': 'Aucun modèle disponible pour {cropName}.',

      'advice_pepper__bell___bacterial_spot':
          'Utilisez des bactéricides à base de cuivre et améliorez la circulation de l’air.',
      'advice_potato___early_blight':
          'Appliquez des fongicides protecteurs comme le Mancozèbe et pratiquez la rotation des cultures.',
      'advice_potato___late_blight':
          'Utilisez des fongicides systémiques (ex. Métalaxyl) et retirez les plants infectés.',

      'advice_tomato_spider_mites_two_spotted_spider_mite':
          'Appliquez des acaricides (ex. Abamectin) et augmentez l’humidité.',
      'advice_tomato__target_spot':
          'Utilisez du Mancozèbe et réduisez l’humidité des feuilles.',
      'advice_tomato__tomato_yellowleaf__curl_virus':
          'Contrôlez les aleurodes avec de l’Imidaclopride et utilisez des variétés résistantes.',
      'advice_tomato__tomato_mosaic_virus':
          'Désinfectez les outils et utilisez des semences certifiées.',

      'confirm_deletion': 'Comfirmation de la suppression',
      'are_you_sure_delete': 'Est vous sure de vouloir supprimer?',
      'yes': 'Oui',

      'no': 'Non',

      'Deconnexion': 'Déconnexion',

      // TreatmentAdviceScreen
      'components': 'Composants',
      'application': 'Application',
      'precaution': 'Précaution',
      'prepare': 'Préparer',
      'per_liter': 'par litre',

      // RecipePreparationPage
      'recipe_preparation_title': 'Préparation de {treatment}',
      'step': 'Étape',
      'pause': 'Pause',
      'resume': 'Reprendre',
      'next': 'Suivant',
      'preparation_complete': 'Préparation terminée !',
      'treatment_not_found': 'Traitement {treatment} non trouvé.',

      'settings_options': 'Options des paramêtres',
      'general_settings': 'Paramètres généraux',

      'marketplace_notifications': 'Notifications de la marketplace',
      'project_notifications': 'Notifications de projet',
      'notify_project_start': 'Début du projet',
      'notify_progress_50': 'Progression à 50%',
      'notify_progress_80': 'Progression à 80%',
      'notify_harvest': 'Rappel de récolte',

      'notification_settings': 'Paramètres des notifications',
      'manage_notifications': 'Gérer les notifications',
      'notify_availability': 'Disponibilité prochaine du produit',
      'notify_message_sent': 'Confirmation d\'envoi de message',
      'notify_low_stock': 'Alerte de stock faible',
      'notify_maturity': 'Maturité du produit atteinte',
      'harvest_days_before': 'Jours avant la récolte',

      'just_now': 'À l’instant',
      'hours_ago': 'Il y a {hours} heure{s}',
      'yesterday': 'Hier',
      'days_ago': 'Il y a {days} jour{s}',
      'weeks_ago': 'Il y a {weeks} semaine{s}',
      'new': 'Nouveau',

      'report': 'Signaler',
      'report_submitted': 'Signalement soumis !',
      'logout': 'Déconnexion',

      'follow': 'Suivre',
      'unfollow': 'Ne plus suivre',
      'message': 'Message',
      'share_profile': 'Partager le profil',
      'profile_shared': 'Profil partagé !',

      'germinating': '{days} jours restants',
      'growing': '{days} jours restants',
      'maturing': '{days} jours restants',
      'debug_maturity_status':
          'Produit : {product}, Phase : {phase}, Jours avant maturité : {daysUntilMaturity}, Période de grâce : {gracePeriodDays}, Visible : {isVisible}',

      'buy_now': 'Payer Maintenant',
      'not_visible_marketplace': 'Plus visible en raison de l\'expiration',

      'pending': 'En attente',

      'no_pending_requests': 'Aucune demande envoyée',

      'request_cancelled': 'Demande annulée avec succès',

      'edit_post_title': 'Modifier la publication',
      'image': 'Image',
      'confirm_delete': 'Confirmer la suppression',
      'delete_post_message':
          'Voulez-vous vraiment supprimer cette publication ? Cette action est irréversible.',

      'comments': 'Commentaires',

      'marketplace_listings': 'Annonces sur la Marketplace',
      'no_listings': 'Aucune annonce disponible',
      'invalid_quantity': 'Quantité invalide',
      'marketplace_stats': 'Statistiques de la Marketplace',
      'statut': 'Statut',
      'publications': 'Publications',
      'quantity_published': 'Quantité publiée',
      'pourcentage_published': 'Pourcentage publié',
      'unit': 'unité',
      'select_quantity': 'Choisir la quantité',
      'remaining_quantity_with_units': 'Quantité restante : {quantity} unités',

      'contact_all_buyers': 'Contacter tous les acheteurs',
      'filter_options': 'Options de filtrage',
      'sort_by_quantity': 'Trier par quantité',
      'sort_by_date': 'Trier par date',
      'sort_by_distance': 'Trier par distance',

      'project_media': "Médias du projet",
      'add_photo': "Ajouter une photo",
      'photo_added':
          "Photo ajoutée avec succès", // Ajout de "avec succès" pour plus de naturel
      'publish_to_news': "Publier dans les actualités",
      'annotate': "Annoter", // Ou "Étiqueter" selon le contexte
      'media_deleted': "Média supprimé",
      'media_details': "Détails du média",
      'published_to_news': "Publié dans les actualités", // Complété la phrase

      'add_media_action': "Ajouter un média (+)",
      'open_camera': "Prendre une photo",
      'open_gallery': "Choisir depuis la galerie",
      'media_added_success': "✓ Média ajouté avec succès",
    },
  };

  static String getTranslation(String key, String locale,
      {Map<String, String>? placeholders}) {
    String text =
        translations[locale]?[key] ?? translations['en']?[key] ?? "[$key]";
    if (placeholders != null) {
      placeholders.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }

  static void debugPrint(String key, String locale,
      {Map<String, String>? placeholders}) {
    final message = getTranslation(key, locale, placeholders: placeholders);
    print(message);
  }
}
