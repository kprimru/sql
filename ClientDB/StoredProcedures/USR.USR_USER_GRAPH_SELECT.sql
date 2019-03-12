USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [USR].[USR_USER_GRAPH_SELECT]
	@COMPLECT	UNIQUEIDENTIFIER,
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME,
	@TYPE		NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;

	IF @START IS NULL
		SET @START = DATEADD(MONTH, -3, GETDATE())
		
	SET @FINISH = DATEADD(DAY, 1, @FINISH)

	SELECT
		UF_DATE, 
		CASE @TYPE 
			WHEN N'OD' THEN t.UF_OD 
			WHEN 'UD' THEN t.UF_UD 
			ELSE 0 
		END AS USR_COUNT
	FROM USR.USRFile f
	INNER JOIN USR.USRFileTech t ON f.UF_ID = t.UF_ID
	WHERE UF_ID_COMPLECT = @COMPLECT
		AND UF_DATE >= @START
		AND (UF_DATE <= @FINISH OR @FINISH IS NULL)
	ORDER BY UF_DATE DESC
END
