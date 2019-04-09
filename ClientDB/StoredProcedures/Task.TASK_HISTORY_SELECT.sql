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
		DATE AS [����], LEFT(CONVERT(VARCHAR(20), TIME, 108), 5) AS [�����], b.NAME AS [������], 
		SHORT AS [���������], NOTE AS [��������], EXPIRE AS [��������� ��], 
		EXEC_DATE AS [���� ����������], EXEC_NOTE AS [�������� � ����������], 
		UPD_DATE AS [���� ��������], UPD_USER AS [��� ������������]
	FROM 
		Task.Tasks a
		INNER JOIN Task.TaskStatus b ON a.ID_STATUS = b.ID
	WHERE ID_MASTER = @ID OR a.ID = @ID
	ORDER BY ID_MASTER, UPD_DATE
END
