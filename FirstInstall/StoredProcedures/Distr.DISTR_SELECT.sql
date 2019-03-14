USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Distr].[DISTR_SELECT]
	@NUM	INT					=	NULL,
	@COMP	TINYINT				=	NULL,
	@SYSTEM	UNIQUEIDENTIFIER	=	NULL,
	@DISTR	UNIQUEIDENTIFIER	=	NULL,
	@NET	UNIQUEIDENTIFIER	=	NULL,
	@TECH	UNIQUEIDENTIFIER	=	NULL,
	@BEGIN	SMALLDATETIME		=	NULL,
	@END	SMALLDATETIME		=	NULL,
	@NOREG	BIT					=	NULL,
	@RC		INT					=	NULL	OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	IF 
		@NUM IS NULL AND 
		@COMP IS NULL AND 
		@SYSTEM IS NULL AND
		@DISTR IS NULL AND
		@NET IS NULL AND
		@TECH IS NULL AND
		@BEGIN IS NULL AND
		@END IS NULL
	BEGIN
		SET @NOREG = 1
	END
	
	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = '
	SELECT 
		DS_ID, 
		HST_ID_MASTER, 
		SYS_ID_MASTER, SYS_SHORT, 
		DS_NUM, DS_COMP, 
		NT_ID_MASTER, NT_NAME, 
		DT_ID_MASTER, DT_NAME, 
		TT_ID_MASTER, TT_NAME, 
		DH_ID, DH_DATE, DH_END, DH_STR, SYS_ORDER
	FROM [Distr].[DistrActive] a /*WITH(NOEXPAND)*/
	WHERE 1 = 1 '

	IF @NUM IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND DS_NUM = @NUM '
	END

	IF @COMP IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND DS_COMP = @COMP '
	END

	IF @SYSTEM IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND SYS_ID_MASTER = @SYSTEM '
	END
			
	IF @DISTR IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND DT_ID_MASTER = @DISTR '
	END

	IF @NET IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND NT_ID_MASTER = @NET '
	END

	IF @TECH IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND TT_ID_MASTER = @TECH '
	END

	IF @BEGIN IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND DH_DATE >= @BEGIN '
	END

	IF @END IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND DH_DATE <= @END '
	END

	IF @NOREG IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND NOT EXISTS
			(
				SELECT *
				FROM Common.RegNodeView b WITH(NOEXPAND)
				WHERE a.SYS_ID_MASTER = b.SYS_ID_MASTER
					AND DS_NUM = RN_DISTR
					AND DS_COMP = RN_COMP
					AND a.NT_ID_MASTER = b.NT_ID_MASTER
					AND a.DT_ID_MASTER = b.DT_ID_MASTER
					AND a.TT_ID_MASTER = b.TT_ID_MASTER		
			)'
	END

	EXEC sp_executesql @SQL, 
		N'
		@NUM	INT,
		@COMP	TINYINT,
		@SYSTEM	UNIQUEIDENTIFIER,
		@DISTR	UNIQUEIDENTIFIER,
		@NET	UNIQUEIDENTIFIER,
		@TECH	UNIQUEIDENTIFIER,
		@BEGIN	SMALLDATETIME,
		@END	SMALLDATETIME',
		@NUM,
		@COMP,
		@SYSTEM,
		@DISTR,
		@NET,
		@TECH,
		@BEGIN,
		@END

	SELECT @RC = @@ROWCOUNT
END
