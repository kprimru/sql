USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[INFO_BANK_SIZE_GRAPH]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@SYS	VARCHAR(MAX),
	@BSIZE	VARCHAR(50) = NULL OUTPUT,
	@ESIZE	VARCHAR(50) = NULL OUTPUT,
	@DELTA	VARCHAR(50) = NULL OUTPUT,
	@PER	DECIMAL(8, 4) = NULL OUTPUT,
	@BEGIN_SIZE	BIGINT = NULL OUTPUT,
	@END_SIZE	BIGINT = NULL OUTPUT,
	@MAX_SIZE	BIGINT = NULL OUTPUT,
	@MIN_SIZE	BIGINT = NULL OUTPUT,
	@BEGIN_DATE	SMALLDATETIME = NULL OUTPUT,
	@END_DATE	SMALLDATETIME = NULL OUTPUT,
	@RESULT		BIT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF OBJECT_ID('tempdb..#system') IS NOT NULL
			DROP TABLE #system

		CREATE TABLE #system (SYS_ID INT PRIMARY KEY)

		IF @SYS IS NULL
			INSERT INTO #system(SYS_ID)
				SELECT SystemID
				FROM dbo.SystemTable
				WHERE SystemActive = 1
		ELSE
			INSERT INTO #system(SYS_ID)
				SELECT SystemID
				FROM dbo.SystemTable INNER JOIN dbo.TableIDFromXML(@SYS) ON ID = SystemID

		SELECT @BEGIN_DATE = MAX(IBS_DATE)
		FROM dbo.InfoBankSizeView WITH(NOEXPAND)
		WHERE IBS_DATE <= @BEGIN

		IF @BEGIN_DATE IS NULL
			SELECT @BEGIN_DATE = MIN(IBS_DATE)
			FROM dbo.InfoBankSizeView WITH(NOEXPAND)
			WHERE IBS_DATE >= @BEGIN


		SELECT @END_DATE = MIN(IBS_DATE)
		FROM dbo.InfoBankSizeView WITH(NOEXPAND)
		WHERE IBS_DATE >= @END

		IF @END_DATE IS NULL
			SELECT @END_DATE = MAX(IBS_DATE)
			FROM dbo.InfoBankSizeView WITH(NOEXPAND)
			WHERE IBS_DATE <= @END

		IF OBJECT_ID('tempdb..#size') IS NOT NULL
			DROP TABLE #size

		CREATE TABLE #size
			(
				ID			INT	IDENTITY(1, 1) PRIMARY KEY,
				IBS_DATE	SMALLDATETIME,
				IBS_SIZE	BIGINT
			)

		INSERT INTO #size (IBS_DATE, IBS_SIZE)
			SELECT IBS_DATE, SUM(IBS_SIZE)
			FROM
				(
					SELECT IBS_DATE, InfoBankID, IBS_SIZE
					FROM
						(
							SELECT IBS_DATE, InfoBankID
							FROM
								(
									SELECT DISTINCT IBS_DATE
									FROM dbo.InfoBankSizeView WITH(NOEXPAND)
								) AS a
								CROSS JOIN
								(
									SELECT DISTINCT InfoBankID
									FROM
										#system
										--ToDo убрать злостный хардкод
										CROSS APPLY dbo.SystemBankGet(SYS_ID, 2)
								) AS b
						) AS t
						CROSS APPLY
						(
							SELECT TOP 1 IBS_SIZE
							FROM dbo.InfoBankSizeView z WITH(NOEXPAND)
							WHERE z.IBF_ID_IB = t.InfoBankID
								AND z.IBS_DATE <= t.IBS_DATE
							ORDER BY z.IBS_DATE DESC
						) AS m

				) AS s
			WHERE IBS_DATE BETWEEN @BEGIN_DATE AND @END_DATE
			GROUP BY IBS_DATE
			ORDER BY IBS_DATE

		DECLARE @PERCENT	DECIMAL(8, 4)

		SELECT @BEGIN_SIZE = IBS_SIZE
		FROM #size
		WHERE IBS_DATE = @BEGIN_DATE

		SELECT @END_SIZE = IBS_SIZE
		FROM #size
		WHERE IBS_DATE = @END_DATE

		IF @BEGIN_SIZE = 0
			SET @PERCENT = 0
		ELSE
			SET @PERCENT = 100 * CONVERT(DECIMAL(18, 4), (@END_SIZE - @BEGIN_SIZE)) / @BEGIN_SIZE

		SELECT IBS_DATE, IBS_SIZE, dbo.FileByteSizeToStr(IBS_SIZE) AS IBS_SIZE_STR, dbo.FileByteSizeToStr(0) AS IBS_DELTA, 0 AS IBS_PERCENT
		FROM #size
		WHERE ID = 1

		UNION ALL

		SELECT IBS_DATE, IBS_SIZE, IBS_SIZE_STR, IBS_DELTA, IBS_PERCENT
		FROM
			(
				SELECT
					a.IBS_DATE, a.IBS_SIZE, dbo.FileByteSizeToStr(a.IBS_SIZE) AS IBS_SIZE_STR,
					dbo.FileByteSizeToStr((a.IBS_SIZE - b.IBS_SIZE)) AS IBS_DELTA,
					(a.IBS_SIZE - b.IBS_SIZE) AS IBS_DELTA_ALL,
					CONVERT(DECIMAL(8, 4),
						100 * CASE
							WHEN ISNULL(b.IBS_SIZE, 0) = 0 THEN 0
							ELSE CONVERT(DECIMAL(18, 4), (a.IBS_SIZE - b.IBS_SIZE)) / b.IBS_SIZE
						END
					)AS IBS_PERCENT
				FROM
					#size a
					INNER JOIN #size b ON a.ID = b.ID + 1
			) AS o_O
		WHERE IBS_DELTA_ALL <> 0

		ORDER BY IBS_DATE DESC

		SELECT @MAX_SIZE = MAX(IBS_SIZE)
		FROM #size

		SELECT @MIN_SIZE = MIN(IBS_SIZE)
		FROM #size

		SELECT
			@BSIZE = dbo.FileByteSizeToStr(@BEGIN_SIZE),
			@ESIZE = dbo.FileByteSizeToStr(@END_SIZE),
			@DELTA = dbo.FileByteSizeToStr(@END_SIZE - @BEGIN_SIZE),
			@PER = @PERCENT

		IF @MAX_SIZE IS NULL OR @MIN_SIZE IS NULL OR @BEGIN_DATE IS NULL OR @END_DATE IS NULL
			SET @RESULT = CONVERT(BIT, 0)
		ELSE
			SET @RESULT = CONVERT(BIT, 1)

		IF OBJECT_ID('tempdb..#system') IS NOT NULL
			DROP TABLE #system

		IF OBJECT_ID('tempdb..#size') IS NOT NULL
			DROP TABLE #size

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INFO_BANK_SIZE_GRAPH] TO rl_info_bank_size_r;
GO
