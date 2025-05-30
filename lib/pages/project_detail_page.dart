import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:jobsy_admin/pages/sidebar.dart';
import '../model/project/project.dart';
import '../provider/auth_provider.dart';
import '../service/admin_service.dart';
import '../service/api_client.dart';
import '../util/routes.dart';
import 'admin_layout.dart';
import '../../util/palette.dart';

class ProjectDetailPage extends StatefulWidget {
  final int projectId;

  const ProjectDetailPage({Key? key, required this.projectId})
    : super(key: key);

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  Project? _project;
  bool _loading = true;
  late AdminService _adminService;

  @override
  void initState() {
    super.initState();
    _initServiceAndLoad();
  }

  Future<void> _initServiceAndLoad() async {
    final auth = context.read<AdminAuthProvider>();
    _adminService = AdminService(
      client: ApiClient(
        baseUrl: Routes.apiBase,
        getToken: () async {
          await auth.ensureLoaded();
          return auth.token;
        },
        refreshToken: () async {
          await auth.refreshTokens();
        },
      ),
    );
    await _loadProject();
  }

  Future<void> _loadProject() async {
    try {
      final project = await _adminService.getProjectById(widget.projectId);
      setState(() {
        _project = project;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      // TODO: Добавьте отображение ошибки
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentSection: AdminSection.projects,
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _project == null
              ? const Center(child: Text('Проект не найден'))
              : _buildContent(_project!),

    );
  }

  Widget _buildContent(Project project) {
    final assignedName =
        project.assignedFreelancer != null
            ? '${project.assignedFreelancer!.basic.firstName} ${project.assignedFreelancer!.basic.lastName}'
            : '—';

    final skillsStr =
        project.skills.isNotEmpty
            ? project.skills.map((s) => s.name).join(', ')
            : '—';

    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 40, 60, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: SvgPicture.asset(
                  'assets/icons/ArrowLeft.svg',
                  width: 20,
                  height: 20,
                  color: Palette.black,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Основная информация',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Удалить проект',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Удалить проект?'),
                          content: Text(
                            'Вы уверены, что хотите удалить проект "${project.title}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Удалить'),
                            ),
                          ],
                        ),
                  );
                  if (confirm == true) {
                    try {
                      await _adminService.deleteProject(project.id);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Проект успешно удалён'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ошибка при удалении: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildField('Заголовок:', project.title),
          _buildField('Категория:', project.category.name),
          _buildField('Специализация:', project.specialization.name),
          _buildField('Описание:', project.description, maxLines: null),
          _buildField('Уровень сложности:', project.complexity.name),
          _buildField('Срок выполнения:', project.duration.name),
          _buildField('Сумма:', project.fixedPrice.toStringAsFixed(2)),
          _buildField('Навыки:', skillsStr),
          _buildField('Исполнитель:', assignedName),
          _buildField('Статус проекта:', project.status.name),
          _buildField('Дата создания:', _formatDate(project.createdAt)),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value, {int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment:
            maxLines! > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              readOnly: true,
              controller: TextEditingController(text: value),
              maxLines: maxLines,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Palette.grey3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Palette.grey3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d.$m.$y';
  }
}
