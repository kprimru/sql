USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [IP].[LIST_FILE_SELECT]
	@LIST	SMALLINT,
	@DT		DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @DT = MAX(LAST_UPDATE)
	FROM IP.Lists
	WHERE TP = @LIST
	
	IF @DT IS NULL
		SET @DT = GETDATE()

	SELECT 
		SystemNumber, DISTR, COMP,
		CONVERT(NVARCHAR(32), SystemNumber) + '_' + CONVERT(NVARCHAR(32), DISTR) + CASE COMP WHEN 1 THEN '' ELSE '_' + CONVERT(NVARCHAR(32), COMP) END AS COMPLECT
	FROM 
		IP.Lists a
		INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.ID_HOST = b.HostID AND a.DISTR = b.DistrNumber AND a.COMP = b.CompNumber
		INNER JOIN dbo.SystemTable c ON b.SystemID = c.SystemID
	WHERE TP = @LIST AND a.UNSET_DATE IS NULL
	ORDER BY c.SystemOrder, DistrNumber, CompNumber	
END
