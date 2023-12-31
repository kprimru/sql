USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Kladr].[KLADR_TREE_SELECT]
	@REGION	NVARCHAR(128),
	@AREA	NVARCHAR(128),
	@CITY	NVARCHAR(128),
	@PUNKT	NVARCHAR(128),
	@STREET	NVARCHAR(128)
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

		IF OBJECT_ID('tempdb..#region') IS NOT NULL
			DROP TABLE #region

		IF OBJECT_ID('tempdb..#area') IS NOT NULL
			DROP TABLE #area

		IF OBJECT_ID('tempdb..#city') IS NOT NULL
			DROP TABLE #city

		IF OBJECT_ID('tempdb..#punkt') IS NOT NULL
			DROP TABLE #punkt

		IF OBJECT_ID('tempdb..#street') IS NOT NULL
			DROP TABLE #street

		CREATE TABLE #region
			(
				KT_ID			UNIQUEIDENTIFIER,
				KT_ID_MASTER	UNIQUEIDENTIFIER,
				KT_NAME			NVARCHAR(128),
				KT_PREFIX		NVARCHAR(32),
				KT_CODE			NVARCHAR(64),
				KT_ACTUAL		NCHAR(4)
			)

		CREATE TABLE #area
			(
				KT_ID			UNIQUEIDENTIFIER,
				KT_ID_MASTER	UNIQUEIDENTIFIER,
				KT_NAME			NVARCHAR(128),
				KT_PREFIX		NVARCHAR(32),
				KT_CODE			NVARCHAR(64),
				KT_ACTUAL		NCHAR(4)
			)

		CREATE TABLE #city
			(
				KT_ID			UNIQUEIDENTIFIER,
				KT_ID_MASTER	UNIQUEIDENTIFIER,
				KT_NAME			NVARCHAR(128),
				KT_PREFIX		NVARCHAR(32),
				KT_CODE			NVARCHAR(64),
				KT_ACTUAL		NCHAR(4)
			)

		CREATE TABLE #punkt
			(
				KT_ID			UNIQUEIDENTIFIER,
				KT_ID_MASTER	UNIQUEIDENTIFIER,
				KT_NAME			NVARCHAR(128),
				KT_PREFIX		NVARCHAR(32),
				KT_CODE			NVARCHAR(64),
				KT_ACTUAL		NCHAR(4)
			)

		CREATE TABLE #street
			(
				KT_ID			UNIQUEIDENTIFIER,
				KT_ID_MASTER	UNIQUEIDENTIFIER,
				KT_NAME			NVARCHAR(128),
				KT_PREFIX		NVARCHAR(32),
				KT_CODE			NVARCHAR(64),
				KT_ACTUAL		NCHAR(4)
			)

		DECLARE @MAX_LEVEL	TINYINT

		SET @MAX_LEVEL = 0

		IF @REGION IS NOT NULL
		BEGIN
			INSERT INTO #region(KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL)
				SELECT KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
				FROM Kladr.KladrTree
				WHERE KT_LEVEL = 1
					AND (
							KT_NAME LIKE @REGION
							OR KT_CODE LIKE @REGION
						)
			SET @MAX_LEVEL = 1
		END

		IF @AREA IS NOT NULL
		BEGIN
			INSERT INTO #area(KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL)
				SELECT KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
				FROM Kladr.KladrTree
				WHERE KT_LEVEL = 2
					AND KT_NAME LIKE @AREA

			SET @MAX_LEVEL = 2
		END

		IF @CITY IS NOT NULL
		BEGIN
			INSERT INTO #city(KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL)
				SELECT KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
				FROM Kladr.KladrTree
				WHERE KT_LEVEL = 3
					AND KT_NAME LIKE @CITY

			SET @MAX_LEVEL = 3
		END

		IF @PUNKT IS NOT NULL
		BEGIN
			INSERT INTO #punkt(KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL)
				SELECT KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
				FROM Kladr.KladrTree
				WHERE KT_LEVEL = 4
					AND KT_NAME LIKE @PUNKT

			SET @MAX_LEVEL = 4
		END

		IF @STREET IS NOT NULL
		BEGIN
			INSERT INTO #street(KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL)
				SELECT KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
				FROM Kladr.KladrTree
				WHERE KT_LEVEL = 5
					AND KT_NAME LIKE @STREET

			SET @MAX_LEVEL = 5
		END

		IF @REGION IS NOT NULL
		BEGIN
			DELETE FROM #area
			WHERE NOT EXISTS
				(
					SELECT *
					FROM #region
					WHERE #area.KT_CODE LIKE #region.KT_CODE + '%'
				)

			DELETE FROM #city
			WHERE NOT EXISTS
				(
					SELECT *
					FROM #region
					WHERE #city.KT_CODE LIKE #region.KT_CODE + '%'
				)

			DELETE FROM #punkt
			WHERE NOT EXISTS
				(
					SELECT *
					FROM #region
					WHERE #punkt.KT_CODE LIKE #region.KT_CODE + '%'
				)

			DELETE FROM #street
			WHERE NOT EXISTS
				(
					SELECT *
					FROM #region
					WHERE #street.KT_CODE LIKE #region.KT_CODE + '%'
				)
		END

		IF @AREA IS NOT NULL
		BEGIN
			DELETE FROM #city
			WHERE NOT EXISTS
				(
					SELECT *
					FROM #area
					WHERE #city.KT_CODE LIKE #area.KT_CODE + '%'
				)

			DELETE FROM #punkt
			WHERE NOT EXISTS
				(
					SELECT *
					FROM #area
					WHERE #punkt.KT_CODE LIKE #area.KT_CODE + '%'
				)

			DELETE FROM #street
			WHERE NOT EXISTS
				(
					SELECT *
					FROM #area
					WHERE #street.KT_CODE LIKE #area.KT_CODE + '%'
				)
		END

		IF @CITY IS NOT NULL
		BEGIN
			DELETE FROM #punkt
			WHERE NOT EXISTS
				(
					SELECT *
					FROM #city
					WHERE #punkt.KT_CODE LIKE #city.KT_CODE + '%'
				)

			DELETE FROM #street
			WHERE NOT EXISTS
				(
					SELECT *
					FROM #city
					WHERE #street.KT_CODE LIKE #city.KT_CODE + '%'
				)
		END

		IF @PUNKT IS NOT NULL
		BEGIN
			DELETE FROM #street
			WHERE NOT EXISTS
				(
					SELECT *
					FROM #punkt
					WHERE #street.KT_CODE LIKE #punkt.KT_CODE + '%'
				)
		END

		IF OBJECT_ID('tempdb..#tree') IS NOT NULL
			DROP TABLE #tree

		CREATE TABLE #tree
			(
				KT_ID			UNIQUEIDENTIFIER,
				KT_ID_MASTER	UNIQUEIDENTIFIER,
				KT_NAME			NVARCHAR(128),
				KT_PREFIX		NVARCHAR(32),
				KT_CODE			NVARCHAR(64),
				KT_LEVEL		TINYINT,
				KT_ACTUAL		NCHAR(4)
			)

		INSERT INTO #tree(KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, KT_LEVEL, KT_ACTUAL)
			SELECT KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, 1, KT_ACTUAL
			FROM #region

			UNION ALL

			SELECT KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, 2, KT_ACTUAL
			FROM #area

			UNION ALL

			SELECT KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, 3, KT_ACTUAL
			FROM #city

			UNION ALL

			SELECT KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, 4, KT_ACTUAL
			FROM #punkt

			UNION ALL

			SELECT KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, 5, KT_ACTUAL
			FROM #street

		DECLARE @I	INT

		SET @I = @MAX_LEVEL

		WHILE @I < 5
		BEGIN
			INSERT INTO #tree(KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, KT_LEVEL, KT_ACTUAL)
				SELECT DISTINCT a.KT_ID, a.KT_ID_MASTER, a.KT_NAME, a.KT_PREFIX, a.KT_CODE, a.KT_LEVEL, a.KT_ACTUAL
				FROM
					Kladr.KladrTree a
					INNER JOIN #tree b ON a.KT_ID_MASTER = b.KT_ID
				WHERE b.KT_LEVEL = @I
					AND NOT EXISTS
						(
							SELECT *
							FROM #tree z
							WHERE z.KT_ID = a.KT_ID
						)

			SET @I = @I + 1
		END

		SET @I = @MAX_LEVEL

		WHILE @I > 1
		BEGIN
			INSERT INTO #tree(KT_ID, KT_ID_MASTER, KT_NAME, KT_PREFIX, KT_CODE, KT_LEVEL, KT_ACTUAL)
				SELECT DISTINCT a.KT_ID, a.KT_ID_MASTER, a.KT_NAME, a.KT_PREFIX, a.KT_CODE, a.KT_LEVEL, a.KT_ACTUAL
				FROM
					Kladr.KladrTree a
					INNER JOIN #tree b ON a.KT_ID = b.KT_ID_MASTER
				WHERE b.KT_LEVEL = @I
					 AND NOT EXISTS
						(
							SELECT *
							FROM #tree z
							WHERE z.KT_ID = a.KT_ID
						)

			SET @I = @I - 1
		END

		SELECT *
		FROM #tree
		ORDER BY KT_LEVEL, KT_NAME, KT_CODE


		IF OBJECT_ID('tempdb..#region') IS NOT NULL
			DROP TABLE #region

		IF OBJECT_ID('tempdb..#area') IS NOT NULL
			DROP TABLE #area

		IF OBJECT_ID('tempdb..#city') IS NOT NULL
			DROP TABLE #city

		IF OBJECT_ID('tempdb..#punkt') IS NOT NULL
			DROP TABLE #punkt

		IF OBJECT_ID('tempdb..#street') IS NOT NULL
			DROP TABLE #street

		IF OBJECT_ID('tempdb..#tree') IS NOT NULL
			DROP TABLE #tree

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Kladr].[KLADR_TREE_SELECT] TO rl_kladr_r;
GO
