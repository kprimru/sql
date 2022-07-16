USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Maintenance].[INDEX_SIZE_SELECT]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		IF OBJECT_ID('tempdb..#index') IS NOT NULL
			DROP TABLE #index

		CREATE TABLE #index
			(
				ID			INT IDENTITY(1, 1) PRIMARY KEY,
				ID_PARENT	INT,
				ID_OBJECT	INT,
				CHECKED		BIT,
				NAME		NVARCHAR(128),
				FRAG		FLOAT,
				PAGE_COUNT	BIGINT,
				LEVEL		TINYINT
			)

		INSERT INTO #index(ID_OBJECT, NAME, LEVEL)
			SELECT object_id, '[' + OBJECT_SCHEMA_NAME(a.object_id) + '].[' + OBJECT_NAME(a.object_id) + ']', 1
			FROM
				(
					SELECT object_id
					FROM sys.tables

					UNION ALL

					SELECT object_id
					FROM sys.views
				) AS a

		INSERT INTO #index(ID_PARENT, CHECKED, NAME, FRAG, PAGE_COUNT, LEVEL)
			SELECT a.ID, 0, b.NAME, avg_fragmentation_in_percent, c.page_count, 2
			FROM
				#index a
				INNER JOIN sys.indexes b ON a.ID_OBJECT = b.object_id
				INNER JOIN sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'LIMITED') AS c ON c.object_id = b.object_id
																								AND c.index_id = b.index_id
			WHERE b.NAME IS NOT NULL


		UPDATE a
		SET PAGE_COUNT	=	(SELECT SUM(b.PAGE_COUNT) FROM #index b WHERE a.ID = b.ID_PARENT),
			FRAG		=	(SELECT MAX(b.FRAG) FROM #index b WHERE a.ID = b.ID_PARENT)
		FROM #index a
		WHERE LEVEL = 1

		UPDATE #index
		SET CHECKED = 1
		WHERE LEVEL = 2
			AND PAGE_COUNT >= 100
			AND FRAG >= 30

		UPDATE a
		SET CHECKED = 1
		FROM #index a
		WHERE LEVEL = 1
			AND NOT EXISTS
				(
					SELECT *
					FROM #index b
					WHERE a.ID = b.ID_PARENT
						AND b.CHECKED = 0
				)

		UPDATE a
		SET CHECKED = 0
		FROM #index a
		WHERE LEVEL = 1
			AND NOT EXISTS
				(
					SELECT *
					FROM #index b
					WHERE a.ID = b.ID_PARENT
						AND b.CHECKED = 1
				)

		SELECT
			ID, ID_PARENT, CHECKED, NAME, FRAG, PAGE_COUNT,
			Common.ByteToStr(CONVERT(BIGINT, PAGE_COUNT) * CONVERT(BIGINT, 8) * CONVERT(BIGINT, 1024)) AS OBJECT_SIZE
		FROM #index
		ORDER BY LEVEL, OBJECT_SCHEMA_NAME(ID_OBJECT), OBJECT_ID(ID_OBJECT), NAME

		IF OBJECT_ID('tempdb..#index') IS NOT NULL
			DROP TABLE #index

		EXEC Maintenance.FINISH_PROC @@PROCID
	END TRY
	BEGIN CATCH
		IF OBJECT_ID('tempdb..#index') IS NOT NULL
			DROP TABLE #index

		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Maintenance.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[INDEX_SIZE_SELECT] TO rl_maintenance_index;
GO
