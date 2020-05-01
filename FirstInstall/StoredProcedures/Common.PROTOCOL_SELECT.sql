USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[PROTOCOL_SELECT]
	@REF	VARCHAR(50),
	@ID		UNIQUEIDENTIFIER,
	@BDATE	DATETIME,
	@EDATE	DATETIME,
	@NOTE	VARCHAR(100),
	@OLD	VARCHAR(100),
	@NEW	VARCHAR(100),
	@RC		INT = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = N'
		SELECT
			PTL_DATE, PTL_USER, PTL_HOST, PTL_REF_NOTE,
			PTL_OLD_VALUE, PTL_NEW_VALUE
		FROM
			Security.Protocol
		WHERE 1 = 1 '

	IF @REF IS NOT NULL
		SET @SQL = @SQL + '
			AND PTL_REFERENCE = @REF '

	IF @ID IS NOT NULL
		SET @SQL = @SQL + '
			AND PTL_KEY = @ID '

	IF @BDATE IS NOT NULL
		SET @SQL = @SQL + '
			AND PTL_DATE >= @BDATE '

	IF @EDATE IS NOT NULL
		SET @SQL = @SQL + '
			AND PTL_DATE <= @EDATE '

	IF @NOTE IS NOT NULL
		SET @SQL = @SQL + '
			AND PTL_REF_NOTE LIKE @NOTE '

	IF @OLD IS NOT NULL
		SET @SQL = @SQL + '
			AND PTL_OLD_VALUE LIKE @OLD '

	IF @NEW IS NOT NULL
		SET @SQL = @SQL + '
			AND PTL_NEW_VALUE LIKE @NEW '

	SET @SQL = @SQL + '
		ORDER BY PTL_DATE DESC'

EXEC sp_executesql @SQL, N'
		@REF	VARCHAR(50),
		@ID		UNIQUEIDENTIFIER,
		@BDATE	DATETIME,
		@EDATE	DATETIME,
		@NOTE	VARCHAR(100),
		@OLD	VARCHAR(100),
		@NEW	VARCHAR(100)',
		@REF, @ID, @BDATE, @EDATE, @NOTE, @OLD, @NEW

	SELECT @RC = @@ROWCOUNT
END
GRANT EXECUTE ON [Common].[PROTOCOL_SELECT] TO rl_protocol_r;
GO