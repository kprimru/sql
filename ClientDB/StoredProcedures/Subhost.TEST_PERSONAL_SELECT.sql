USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Subhost].[TEST_PERSONAL_SELECT]
	@SUBHOST	UNIQUEIDENTIFIER,
	@LGN		NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.ID, b.NAME, a.START, a.FINISH, Common.TimeSecToStr(DATEDIFF(SECOND, a.START, a.FINISH)) AS LN,
		CASE 
			WHEN FINISH IS NULL THEN '�������'
			ELSE
				CASE ISNULL((SELECT RESULT FROM Subhost.CheckTest z WHERE z.ID_TEST = a.ID), 200)
					WHEN 200 THEN '�� ��������'
					WHEN 0 THEN '�� ����'
					WHEN 1 THEN '����'
					ELSE '����������'
				END
		END AS RES,
		(
			SELECT TOP 1 z.NOTE
			FROM 
				Subhost.CheckTest z
			WHERE z.ID_TEST = a.ID
		) AS RESULT_NOTE
	FROM 
		Subhost.PersonalTest a
		INNER JOIN Subhost.Test b ON a.ID_TEST = b.ID
	WHERE ID_SUBHOST = @SUBHOST
		AND PERSONAL = @LGN
	ORDER BY START DESC
END
