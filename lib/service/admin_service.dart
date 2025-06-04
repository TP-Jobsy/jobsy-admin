import '../model/client/client_profile.dart';
import '../model/free/freelancer_profile.dart';
import '../model/page_response.dart';
import '../model/portfolio/portfolio.dart';
import '../model/portfolio_admin_list_item.dart';
import '../model/project/project.dart';
import '../model/project_admin_list_item.dart';
import '../model/user/user.dart';
import 'api_client.dart';

class AdminService {
  final ApiClient _api;

  AdminService({required ApiClient client}) : _api = client;

  Future<List<FreelancerProfile>> getAllFreelancers() async {
    final json = await _api.get<List<dynamic>>(
      '/admin/freelancers',
      decoder: (data) => data,
    );
    return json!
        .cast<Map<String, dynamic>>()
        .map(FreelancerProfile.fromJson)
        .toList();
  }

  Future<FreelancerProfile> getFreelancerById(int userId) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/admin/freelancers/$userId',
      decoder: (data) => data,
    );
    return FreelancerProfile.fromJson(json!);
  }

  Future<void> deleteFreelancer(int userId) async {
    await _api.delete<void>('/admin/freelancers/$userId');
  }

  Future<List<ClientProfile>> getAllClients() async {
    final json = await _api.get<List<dynamic>>(
      '/admin/clients',
      decoder: (data) => data,
    );
    return json!
        .cast<Map<String, dynamic>>()
        .map(ClientProfile.fromJson)
        .toList();
  }

  Future<ClientProfile> getClientById(int userId) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/admin/clients/$userId',
      decoder: (data) => data,
    );
    return ClientProfile.fromJson(json!);
  }

  Future<void> deleteClient(int userId) async {
    await _api.delete<void>('/admin/clients/$userId');
  }

  Future<ClientProfile> getClientByUserId(int userId) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/admin/clients/$userId',
      decoder: (data) => data,
    );
    return ClientProfile.fromJson(json!);
  }

  Future<List<Project>> getClientProjects(int userId) async {
    final clientProfile = await getClientByUserId(userId);
    final clientProfileId = clientProfile.id;

    final json = await _api.get<List<dynamic>>(
      '/admin/clients/$clientProfileId/projects',
      decoder: (data) => data,
    );
    return json!
        .cast<Map<String, dynamic>>()
        .map(Project.fromJson)
        .toList();
  }

  Future<Project> getProjectById(int projectId) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/admin/projects/$projectId',
      decoder: (data) => data,
    );
    return Project.fromJson(json!);
  }

  Future<void> deleteProject(int projectId) async {
    await _api.delete<void>('/admin/projects/$projectId');
  }

  Future<List<FreelancerPortfolio>> getFreelancerPortfolio(
    int freelancerId,
  ) async {
    final json = await _api.get<List<dynamic>>(
      '/admin/freelancers/$freelancerId/portfolio',
      decoder: (data) => data,
    );
    return json!
        .cast<Map<String, dynamic>>()
        .map(FreelancerPortfolio.fromJson)
        .toList();
  }

  Future<void> deletePortfolio(int freelancerId, int portfolioId) async {
    await _api.delete<void>(
      '/admin/freelancers/$freelancerId/portfolio/$portfolioId',
    );
  }

  Future<PageResponse<ProjectAdminListItem>> fetchProjectsPage(
    int page,
    int size,
  ) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/admin/projects?page=$page&size=$size',
      decoder: (data) => data,
    );
    return PageResponse<ProjectAdminListItem>.fromJson(
      json!,
      (item) => ProjectAdminListItem.fromJson(item),
    );
  }

  Future<PageResponse<PortfolioAdminListItem>> fetchPortfoliosPage(
    int page,
    int size,
  ) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/admin/portfolios?page=$page&size=$size',
      decoder: (data) => data,
    );
    return PageResponse<PortfolioAdminListItem>.fromJson(
      json!,
      (item) => PortfolioAdminListItem.fromJson(item),
    );
  }

  Future<FreelancerPortfolio> getPortfolioById(int portfolioId) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/admin/portfolios/$portfolioId',
      decoder: (data) => data,
    );
    return FreelancerPortfolio.fromJson(json!);
  }

  Future<PageResponse<User>> searchUsers({
    String? term,
    String? role,
    DateTime? registeredFrom,
    DateTime? registeredTo,
    int page = 0,
    int size = 20,
  }) async {
    final query = {
      if (term != null && term.isNotEmpty) 'term': term,
      if (role != null) 'role': role,
      if (registeredFrom != null)
        'registeredFrom': registeredFrom.toIso8601String(),
      if (registeredTo != null) 'registeredTo': registeredTo.toIso8601String(),
      'page': '$page',
      'size': '$size',
    };

    final json = await _api.get<Map<String, dynamic>>(
      '/admin/users/search',
      queryParameters: query,
      decoder: (data) => data,
    );

    return PageResponse<User>.fromJson(json!, (item) => User.fromJson(item));
  }

  Future<PageResponse<ProjectAdminListItem>> searchProjects({
    String? term,
    String? status,
    DateTime? createdFrom,
    DateTime? createdTo,
    int page = 0,
    int size = 20,
  }) async {
    final query = <String, String>{
      if (term != null && term.isNotEmpty) 'term': term,
      if (status != null && status.isNotEmpty) 'status': status,
      if (createdFrom != null) 'createdFrom': createdFrom.toIso8601String(),
      if (createdTo != null) 'createdTo': createdTo.toIso8601String(),
      'page': '$page',
      'size': '$size',
    };

    final json = await _api.get<Map<String, dynamic>>(
      '/admin/projects/search',
      queryParameters: query,
      decoder: (d) => d,
    );

    return PageResponse<ProjectAdminListItem>.fromJson(
      json!,
      (item) => ProjectAdminListItem.fromJson(item),
    );
  }

  Future<PageResponse<PortfolioAdminListItem>> searchPortfolios({
    String? term,
    DateTime? createdFrom,
    DateTime? createdTo,
    int page = 0,
    int size = 20,
  }) async {
    final query = <String, String>{
      if (term != null && term.isNotEmpty) 'term': term,
      if (createdFrom != null) 'createdFrom': createdFrom.toIso8601String(),
      if (createdTo != null) 'createdTo': createdTo.toIso8601String(),
      'page': '$page',
      'size': '$size',
    };

    final json = await _api.get<Map<String, dynamic>>(
      '/admin/portfolios/search',
      queryParameters: query,
      decoder: (d) => d,
    );

    return PageResponse<PortfolioAdminListItem>.fromJson(
      json!,
      (item) => PortfolioAdminListItem.fromJson(item),
    );
  }

  Future<void> activateFreelancer(int userId) async {
    await _api.put<void>(
      '/admin/freelancers/$userId/activate',
      expectCode: 200,
    );
  }

  Future<void> deactivateFreelancer(int userId) async {
    await _api.put<void>(
      '/admin/freelancers/$userId/deactivate',
      expectCode: 200,
    );
  }

  Future<void> activateClient(int userId) async {
    await _api.put<void>('/admin/clients/$userId/activate', expectCode: 200);
  }

  Future<void> deactivateClient(int userId) async {
    await _api.put<void>('/admin/clients/$userId/deactivate', expectCode: 200);
  }

  Future<List<Project>> getFreelancerProjects(int freelancerId) async {
    final json = await _api.get<List<dynamic>>(
      '/admin/freelancers/$freelancerId/projects',
      decoder: (data) => data,
    );
    return json!.cast<Map<String, dynamic>>().map(Project.fromJson).toList();
  }
}
