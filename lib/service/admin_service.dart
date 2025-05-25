import '../model/client/client_profile.dart';
import '../model/free/freelancer_profile.dart';
import '../model/page_response.dart';
import '../model/portfolio/portfolio.dart';
import '../model/portfolio_admin_list_item.dart';
import '../model/project/project.dart';
import '../model/project_admin_list_item.dart';
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

  Future<List<Project>> getClientProjects(int clientId) async {
    final json = await _api.get<List<dynamic>>(
      '/admin/clients/$clientId/projects',
      decoder: (data) => data,
    );
    return json!.cast<Map<String, dynamic>>().map(Project.fromJson).toList();
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
}
