import '../model/client/client_profile.dart';
import '../model/free/freelancer_profile.dart';
import '../model/page_response.dart';
import '../model/portfolio/portfolio.dart';
import '../model/portfolio_admin_list_item.dart';
import '../model/project/project.dart';
import '../model/project_admin_list_item.dart';
import '../util/routes.dart';
import 'api_client.dart';

class AdminService {
  final ApiClient _api;

  AdminService({ApiClient? client})
    : _api = client ?? ApiClient(baseUrl: Routes.apiBase);

  Future<List<FreelancerProfile>> getAllFreelancers(String token) async {
    final json = await _api.get<List<dynamic>>(
      '/admin/freelancers',
      token: token,
    );
    return json!
        .cast<Map<String, dynamic>>()
        .map(FreelancerProfile.fromJson)
        .toList();
  }

  Future<FreelancerProfile> getFreelancerById(String token, int userId) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/admin/freelancers/$userId',
      token: token,
    );
    return FreelancerProfile.fromJson(json!);
  }

  Future<void> deleteFreelancer(String token, int userId) async {
    await _api.delete<void>('/admin/freelancers/$userId', token: token);
  }

  Future<List<ClientProfile>> getAllClients(String token) async {
    final json = await _api.get<List<dynamic>>('/admin/clients', token: token);
    return json!
        .cast<Map<String, dynamic>>()
        .map(ClientProfile.fromJson)
        .toList();
  }

  Future<ClientProfile> getClientById(String token, int userId) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/admin/clients/$userId',
      token: token,
    );
    return ClientProfile.fromJson(json!);
  }

  Future<void> deleteClient(String token, int userId) async {
    await _api.delete<void>('/admin/clients/$userId', token: token);
  }

  Future<List<Project>> getClientProjects(String token, int clientId) async {
    final json = await _api.get<List<dynamic>>(
      '/admin/clients/$clientId/projects',
      token: token,
    );
    return json!.cast<Map<String, dynamic>>().map(Project.fromJson).toList();
  }

  Future<Project> getProjectById(String token, int projectId) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/admin/projects/$projectId',
      token: token,
    );
    return Project.fromJson(json!);
  }

  Future<void> deleteProject(String token, int projectId) async {
    await _api.delete<void>('/admin/projects/$projectId', token: token);
  }

  Future<List<FreelancerPortfolio>> getFreelancerPortfolio(
    String token,
    int freelancerId,
  ) async {
    final json = await _api.get<List<dynamic>>(
      '/admin/freelancers/$freelancerId/portfolio',
      token: token,
    );
    return json!
        .cast<Map<String, dynamic>>()
        .map(FreelancerPortfolio.fromJson)
        .toList();
  }

  Future<void> deletePortfolio(
    String token,
    int freelancerId,
    int portfolioId,
  ) async {
    await _api.delete<void>(
      '/admin/freelancers/$freelancerId/portfolio/$portfolioId',
      token: token,
    );
  }

  Future<PageResponse<ProjectAdminListItem>> fetchProjectsPage(
    String token,
    int page,
    int size,
  ) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/admin/projects?page=$page&size=$size',
      token: token,
    );
    return PageResponse<ProjectAdminListItem>.fromJson(
      json!,
      (item) => ProjectAdminListItem.fromJson(item),
    );
  }

  Future<PageResponse<PortfolioAdminListItem>> fetchPortfoliosPage(
    String token,
    int page,
    int size,
  ) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/admin/portfolios?page=$page&size=$size',
      token: token,
    );
    return PageResponse<PortfolioAdminListItem>.fromJson(
      json!,
      (item) => PortfolioAdminListItem.fromJson(item),
    );
  }

  Future<FreelancerPortfolio> getPortfolioById(
    String token,
    int portfolioId,
  ) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/admin/portfolios/$portfolioId',
      token: token,
    );
    return FreelancerPortfolio.fromJson(json!);
  }
}
