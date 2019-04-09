USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Poll].[BLANK_QUESTION_SELECT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ID, NAME, ORD, ANS_MIN, ANS_MAX, TP, 
		CASE TP
			WHEN 0 THEN '����������� �����'
			WHEN 1 THEN '������������ �����'
			WHEN 2 THEN '��������� ���� ��� �����'
			WHEN 3 THEN '����� �� ���������'
		END AS TP_STR
	FROM Poll.Question
	WHERE ID_BLANK = @ID
	ORDER BY ORD
END
