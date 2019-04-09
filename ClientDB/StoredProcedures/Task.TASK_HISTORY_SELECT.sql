USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Task].[TASK_HISTORY_SELECT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		DATE AS [Дата], LEFT(CONVERT(VARCHAR(20), TIME, 108), 5) AS [Время], b.NAME AS [Статус], 
		SHORT AS [Заголовок], NOTE AS [Описание], EXPIRE AS [Выполнить до], 
		EXEC_DATE AS [Дата выполнения], EXEC_NOTE AS [Описание к выполнению], 
		UPD_DATE AS [Дата редакции], UPD_USER AS [Кто редактировал]
	FROM 
		Task.Tasks a
		INNER JOIN Task.TaskStatus b ON a.ID_STATUS = b.ID
	WHERE ID_MASTER = @ID OR a.ID = @ID
	ORDER BY ID_MASTER, UPD_DATE
END
