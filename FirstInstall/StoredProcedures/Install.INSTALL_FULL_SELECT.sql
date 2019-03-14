USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	


CREATE PROCEDURE [Install].[INSTALL_FULL_SELECT]
	@BDATE		SMALLDATETIME	= NULL,
	@EDATE		SMALLDATETIME	= NULL,
	@CLIENT		VARCHAR(50)		= NULL,
	@NODISTR	BIT				= NULL,
	@NOCLAIM	BIT				= NULL,
	@NOINSTALL	BIT				= NULL,
	@NOACT		BIT				= NULL,
	@RC			INT				= NULL OUTPUT,
	@DISTR		VARCHAR(20)		= NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = '
	SELECT 
		INS_ID, IND_ID, --INS_DATE,
		IN_DATE, ID_FULL_PAY,
		CL_ID_MASTER, CL_NAME, 
		VD_ID_MASTER, VD_NAME, 
		ID_COMMENT,		
		SYS_ID_MASTER, SYS_SHORT, 
		DT_ID_MASTER, DT_SHORT AS DT_NAME, 
		NT_ID_MASTER, --NT_NAME, 
		TT_ID_MASTER, --TT_NAME,
		NT_NEW_NAME,
		IND_DISTR,
		PER_ID_MASTER, PER_NAME AS IND_PERSONAL, --PER_NAME,
		IND_INSTALL_DATE, IND_ARCHIVE,
		IND_CONTRACT, CLM_ID, CLM_DATE, IND_CLAIM,
		IND_ACT_DATE, IND_ACT_RETURN, IND_LOCK, IND_COMMENTS, 
		IND_COMMENTS AS IND_COMMENTS_STR, ID_RESTORE, ID_EXCHANGE, ID_LOCK,
		IA_ID_MASTER, IA_NAME, IA_NORM, IND_ACT_NOTE,
		IND_TO_NUM, IND_LIMIT, ID_PERSONAL
	FROM Install.InstallFullView
	WHERE 1 = 1 '

	IF @BDATE IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND INS_DATE >= @BDATE '
	END

	IF @EDATE IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND INS_DATE <= @EDATE '
	END
		
	IF @CLIENT IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND CL_NAME LIKE @CLIENT '
	END

	IF @NODISTR	IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND (IND_DISTR IS NULL OR (LTRIM(RTRIM(IND_DISTR)) = '''')) '
	END

	IF @NOCLAIM	IS NOT NULL AND @NODISTR IS NULL
	BEGIN
		SET @SQL = @SQL + ' AND IND_CLAIM IS NULL '
	END

	IF @NOINSTALL IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND IND_INSTALL_DATE IS NULL '
	END

	IF @NOACT IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND IND_ACT_RETURN IS NULL '
	END

	IF @DISTR IS NOT NULL
		SET @SQL = @SQL + ' AND IND_DISTR LIKE @DISTR '

	EXEC sp_executesql @SQL, N'
		@BDATE		SMALLDATETIME,
		@EDATE		SMALLDATETIME,
		@CLIENT		VARCHAR(50),
		@DISTR		VARCHAR(20)',
		@BDATE, @EDATE, @CLIENT, @DISTR

	SELECT @RC = @@ROWCOUNT
END



