USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[TEST_RESULT_SELECT]
	@SUBHOST	UNIQUEIDENTIFIER,
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	SET @FINISH = DATEADD(DAY, 1, @FINISH)

	SELECT 
		a.ID, b.NAME, PERSONAL, START, FINISH, 
		Common.TimeSecToStr(DATEDIFF(SECOND, a.START, a.FINISH)) AS LN,
		(
			SELECT COUNT(*)
			FROM Subhost.PersonalTestQuestion z
			WHERE z.ID_TEST = a.ID
		) AS QST_CNT,
		(
			SELECT COUNT(*)
			FROM 
				Subhost.CheckTest z
				INNER JOIN Subhost.CheckTestQuestion y ON z.ID = y.ID_TEST
			WHERE z.ID_TEST = a.ID
				AND y.RESULT = 1
		) AS RIGHT_CNT,
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
	WHERE a.ID_SUBHOST = @SUBHOST
		AND (START >= @START OR @START IS NULL)
		AND (START < @FINISH OR @FINISH IS NULL)
		AND FINISH IS NOT NULL
	ORDER BY START DESC
END
