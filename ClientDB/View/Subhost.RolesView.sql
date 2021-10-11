USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Subhost].[RolesView]
AS
	SELECT 10 AS ORD, 'rl_user_admin' AS RL_NAME, 'Управление пользователями (создание/удаление/смена пароля)' AS RL_CAPTION
	UNION ALL
	SELECT 20 AS ORD, 'rl_letter_base' AS RL_NAME, 'База писем' AS RL_CAPTION
	UNION ALL
	SELECT 30 AS ORD, 'rl_ip' AS RL_NAME, 'ИнтернетПополнение клиентов' AS RL_CAPTION
	UNION ALL
	SELECT 40 AS ORD, 'rl_zve' AS RL_NAME, 'Просмотр вопросов по кнопке "Задать вопрос"' AS RL_CAPTION
	UNION ALL
	SELECT 50 AS ORD, 'rl_hotline_chat' AS RL_NAME, 'Просмотр чатов с клиентами' AS RL_CAPTION
	UNION ALL
	SELECT 60 AS ORD, 'rl_download_document' AS RL_NAME, 'Скачанные документы' AS RL_CAPTION
	UNION ALL
	SELECT 70 AS ORD, 'rl_test' AS RL_NAME, 'Возможность тестирования' AS RL_CAPTION
	UNION ALL
	SELECT 80 AS ORD, 'rl_test_admin' AS RL_NAME, 'Просмотр результатов тестирования' AS RL_CAPTION
	UNION ALL
	SELECT 90 AS ORD, 'rl_import_data' AS RL_NAME, 'Данные для импорта данных из РИЦ' AS RL_CAPTION
	UNION ALL
	SELECT 100 AS ORD, 'rl_import_online' AS RL_NAME, 'Данные по активности онлайн-клиентов' AS RL_CAPTION
	UNION ALL
	SELECT 110 AS ORD, 'rl_import_usr' AS RL_NAME, 'Данные по файлам USR' AS RL_CAPTION
	UNION ALL
	SELECT 120 AS ORD, 'rl_import_dbf' AS RL_NAME, 'Данные для импорта из DBF' AS RL_CAPTION
	UNION ALL
	SELECT 130 AS ORD, 'rl_import_discount' AS RL_NAME, 'Отчет по реальной скидке' AS RL_CAPTION
	UNION ALL
	SELECT 140 AS ORD, 'rl_zve_infiltration' AS RL_NAME, 'Отчет по внедрению ЗВЭ' AS RL_CAPTION
	UNION ALL
	SELECT 150 AS ORD, 'rl_stt' AS RL_NAME, 'Просмотр данных по СТТ' AS RL_CAPTION
	UNION ALL
	SELECT 160 AS ORD, 'rl_stt_load' AS RL_NAME, 'Загрузка файлов STT' AS RL_CAPTION
	/*
	UNION ALL
	SELECT 1 AS ORD, 'rl_knowlenge' AS RL_NAME, 'База знаний' AS RL_CAPTION
	*/
GO
