import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promptify/providers/script_provider.dart';
import 'package:promptify/services/script_service.dart';

/// 打开文件屏幕
///
/// 提供两种方式加载稿件：
/// 1. 从文件系统选择.txt文件
/// 2. 从数据库加载之前保存的稿件
class OpenFileScreen extends ConsumerWidget {
  const OpenFileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scriptService = ref.watch(scriptServiceProvider.notifier);

    // FutureBuilder等待获取稿件流
    return FutureBuilder(
      future: scriptService.getScripts(),
      // StreamBuilder监听稿件列表的实时更新
      builder: (buildContext, streamSnapshot) => StreamBuilder(
        stream: streamSnapshot.data,
        builder: (context, snapshot) => Scaffold(
          appBar: AppBar(title: Text(context.tr("OpenFileScreen.title"))),
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 从文件系统选择按钮
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // 打开文件选择器，只允许选择.txt文件
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['txt'],
                        );
                        if (result != null) {
                          final file = result.files.first;

                          // 读取文件内容
                          final fileContent = await File(
                            file.path!,
                          ).readAsString();

                          // 将内容加载到稿件Provider
                          ref
                              .read(scriptProvider.notifier)
                              .setText(fileContent);
                          ref.read(scriptProvider.notifier).setTitle(file.name);
                          // 返回主页
                          context.pop();
                        }
                      },
                      child: Text(
                        context.tr("OpenFileScreen.ElevatedButton_Select"),
                      ),
                    ),
                  ),
                ],
              ),
              if (snapshot.data == null || snapshot.data!.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  child: Text(
                    context.tr("OpenFileScreen.if_empty"),
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (snapshot.data != null && snapshot.data!.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (itemContext, index) {
                      final script = snapshot.data![index];
                      return ListTile(
                        title: Text(
                          script.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          script.createdAt.toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () async {
                          ref
                              .read(scriptProvider.notifier)
                              .setText(
                                (await scriptService.loadScript(script.id)),
                              );

                          context.pop();
                        },
                        trailing: IconButton(
                          tooltip: context.tr("OpenFileScreen.ListTile_Delete"),
                          onPressed: () {
                            scriptService.deleteScript(script.id);
                          },
                          icon: Icon(Icons.delete),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
