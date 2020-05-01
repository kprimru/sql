USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Kladr].[KLADR_TREE_CREATE]
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

		TRUNCATE TABLE Kladr.KladrTree

		/*
			испорт списка регионов (1-го уровня)
		*/
		INSERT INTO Kladr.KladrTree
			(
				KT_ID_MASTER, KT_LEVEL, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
			)
			SELECT NULL, 1, KL_NAME, KL_SOCR, LEFT(KL_CODE, 2), RIGHT(KL_CODE, 2)
			FROM Kladr.Kladr
			WHERE KL_CODE LIKE N'__000000000__'
			/*
				последние 2 цифры - признак актуальности. Первые две - код региона
			*/

		
		/*
			Импорт районов (2-го уровня)
		*/
		INSERT INTO Kladr.KladrTree
			(
				KT_ID_MASTER, KT_LEVEL, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
			)
			SELECT 
				(
					SELECT KT_ID
					FROM Kladr.KladrTree
					WHERE KT_CODE = LEFT(KL_CODE, 2)
						--AND KT_LEVEL = 1
						AND KT_ACTUAL = N'00'
				), 2, KL_NAME, KL_SOCR, LEFT(KL_CODE, 5), RIGHT(KL_CODE, 2)
			FROM Kladr.Kladr
			WHERE KL_CODE LIKE N'_____000000__'
				AND NOT (KL_CODE LIKE N'__000000000__')
				AND EXISTS
					(					
						SELECT *
						FROM Kladr.KladrTree
						WHERE KT_CODE = LEFT(KL_CODE, 2)
							--AND KT_LEVEL = 1
							AND KT_ACTUAL = N'00'				
					)

		/*
			Импорт населенных пунктов (3-го уровня)
		*/
		INSERT INTO Kladr.KladrTree
			(
				KT_ID_MASTER, KT_LEVEL, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
			)
			SELECT
				(
					SELECT KT_ID
					FROM Kladr.KladrTree
					WHERE KT_CODE = LEFT(KL_CODE, 5)
						--AND KT_LEVEL = 2
						AND KT_ACTUAL = N'00'
				), 3, KL_NAME, KL_SOCR, LEFT(KL_CODE, 8), RIGHT(KL_CODE, 2)
			FROM Kladr.Kladr
			WHERE KL_CODE LIKE N'________000__'
				AND NOT (KL_CODE LIKE N'_____000000__')
				AND EXISTS
					(
						SELECT *
						FROM Kladr.KladrTree
						WHERE KT_CODE = LEFT(KL_CODE, 5)
							--AND KT_LEVEL = 2
							AND KT_ACTUAL = N'00'
					)

		/*
			Импорт населенных пунктов 3-го уровня, которые не привязаны к объектам 2-го уровня
			(сразу к регионам, как, например, г.Владивосток)
		*/	
		INSERT INTO Kladr.KladrTree
			(
				KT_ID_MASTER, KT_LEVEL, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
			)
			SELECT
				(
					SELECT KT_ID
					FROM Kladr.KladrTree
					WHERE KT_CODE = LEFT(KL_CODE, 2)
						--AND KT_LEVEL = 2
						AND KT_ACTUAL = N'00'
				), 3, KL_NAME, KL_SOCR, LEFT(KL_CODE, 8), RIGHT(KL_CODE, 2)
			FROM Kladr.Kladr
			WHERE KL_CODE LIKE N'__000___000__'			
				AND NOT (KL_CODE LIKE N'_____000000__')
				AND EXISTS
					(
						SELECT KT_ID
						FROM Kladr.KladrTree
						WHERE KT_CODE = LEFT(KL_CODE, 2)
							--AND KT_LEVEL = 2
							AND KT_ACTUAL = N'00'
					)
		
		/*
			Имспорт населенных пунктов 4-го уровня
		*/

		INSERT INTO Kladr.KladrTree
			(
				KT_ID_MASTER, KT_LEVEL, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
			)
			SELECT
				(
					SELECT KT_ID
					FROM Kladr.KladrTree
					WHERE KT_CODE = LEFT(KL_CODE, 8)
						--AND KT_LEVEL = 3
						AND KT_ACTUAL = N'00'
				), 4, KL_NAME, KL_SOCR, LEFT(KL_CODE, 11), RIGHT(KL_CODE, 2)
			FROM Kladr.Kladr
			WHERE KL_CODE LIKE N'_____________'
				AND NOT (KL_CODE LIKE N'________000__')
				AND EXISTS
					(
						SELECT *
						FROM Kladr.KladrTree
						WHERE KT_CODE = LEFT(KL_CODE, 8)
							--AND KT_LEVEL = 3
							AND KT_ACTUAL = N'00'
					)

		/*
			Испорт населенных объектов 4-го уровня, которые не привязаны к объектам 3-го уровня
		*/	
		INSERT INTO Kladr.KladrTree
			(
				KT_ID_MASTER, KT_LEVEL, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
			)
			SELECT
				(
					SELECT KT_ID
					FROM Kladr.KladrTree
					WHERE KT_CODE = LEFT(KL_CODE, 5)
						--AND KT_LEVEL = 3
						AND KT_ACTUAL = N'00'
				), 4, KL_NAME, KL_SOCR, LEFT(KL_CODE, 11), RIGHT(KL_CODE, 2)
			FROM Kladr.Kladr
			WHERE KL_CODE LIKE N'_____000_____'
				AND NOT (KL_CODE LIKE N'________000__')
				AND EXISTS
					(
						SELECT KT_ID
						FROM Kladr.KladrTree
						WHERE KT_CODE = LEFT(KL_CODE, 5)
							--AND KT_LEVEL = 3
							AND KT_ACTUAL = N'00'
					)

		/*
			Испорт населенных объектов 4-го уровня, которые не привязаны к объектам 3-го и 2-го уровня
		*/
		INSERT INTO Kladr.KladrTree
			(
				KT_ID_MASTER, KT_LEVEL, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
			)
			SELECT
				(
					SELECT KT_ID
					FROM Kladr.KladrTree
					WHERE KT_CODE = LEFT(KL_CODE, 2)
						--AND KT_LEVEL = 3
						AND KT_ACTUAL = N'00'
				), 4, KL_NAME, KL_SOCR, LEFT(KL_CODE, 11), RIGHT(KL_CODE, 2)
			FROM Kladr.Kladr
			WHERE KL_CODE LIKE N'__000000_____'
				AND NOT (KL_CODE LIKE N'________000__')
				AND EXISTS
					(			
						SELECT KT_ID
						FROM Kladr.KladrTree
						WHERE KT_CODE = LEFT(KL_CODE, 2)
							--AND KT_LEVEL = 3
							AND KT_ACTUAL = N'00'			
					)

		/*
			Импорт улиц
		*/
		INSERT INTO Kladr.KladrTree
			(
				KT_ID_MASTER, KT_LEVEL, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
			)
			SELECT
				(
					SELECT KT_ID
					FROM Kladr.KladrTree
					WHERE KT_CODE = LEFT(KS_CODE, 11)
						--AND KT_LEVEL = 4
						AND KT_ACTUAL = N'00'
				), 5, KS_NAME, KS_SOCR, LEFT(KS_CODE, 15), RIGHT(KS_CODE, 2)
			FROM Kladr.Street
			WHERE KS_CODE LIKE N'%__'
				AND EXISTS
					(
						SELECT *
						FROM Kladr.KladrTree
						WHERE KT_CODE = LEFT(KS_CODE, 11)
							--AND KT_LEVEL = 4
							AND KT_ACTUAL = N'00'
					)

		/*
			Импорт улиц без населенных пунктов 4-го уровня
		*/
		INSERT INTO Kladr.KladrTree
			(
				KT_ID_MASTER, KT_LEVEL, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
			)
			SELECT
				(
					SELECT KT_ID
					FROM Kladr.KladrTree
					WHERE KT_CODE = LEFT(KS_CODE, 8)
						--AND KT_LEVEL = 4
						AND KT_ACTUAL = N'00'
				), 5, KS_NAME, KS_SOCR, LEFT(KS_CODE, 15), RIGHT(KS_CODE, 2)
			FROM Kladr.Street
			WHERE KS_CODE LIKE N'________000______'
				AND EXISTS
					(
						SELECT *
						FROM Kladr.KladrTree
						WHERE KT_CODE = LEFT(KS_CODE, 8)
							--AND KT_LEVEL = 4
							AND KT_ACTUAL = N'00'
					)

		/*
			Импорт улиц без населенных пунктов 4-го и 3-го уровня
		*/
		INSERT INTO Kladr.KladrTree
			(
				KT_ID_MASTER, KT_LEVEL, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
			)
			SELECT
				(
					SELECT KT_ID
					FROM Kladr.KladrTree
					WHERE KT_CODE = LEFT(KS_CODE, 5)
						--AND KT_LEVEL = 4
						AND KT_ACTUAL = N'00'
				), 5, KS_NAME, KS_SOCR, LEFT(KS_CODE, 15), RIGHT(KS_CODE, 2)
			FROM Kladr.Street
			WHERE KS_CODE LIKE N'_____000000______'
				AND EXISTS
					(
						SELECT *
						FROM Kladr.KladrTree
						WHERE KT_CODE = LEFT(KS_CODE, 5)
							--AND KT_LEVEL = 4
							AND KT_ACTUAL = N'00'
					)

		/*
			Импорт улиц без районов
		*/
		INSERT INTO Kladr.KladrTree
			(
				KT_ID_MASTER, KT_LEVEL, KT_NAME, KT_PREFIX, KT_CODE, KT_ACTUAL
			)
			SELECT
				(
					SELECT KT_ID
					FROM Kladr.KladrTree
					WHERE KT_CODE = LEFT(KS_CODE, 2)
						--AND KT_LEVEL = 4
						AND KT_ACTUAL = N'00'
				), 5, KS_NAME, KS_SOCR, LEFT(KS_CODE, 15), RIGHT(KS_CODE, 2)
			FROM Kladr.Street
			WHERE KS_CODE LIKE N'__000000000______'
				AND EXISTS
					(
						SELECT *
						FROM Kladr.KladrTree
						WHERE KT_CODE = LEFT(KS_CODE, 2)
							--AND KT_LEVEL = 4
							AND KT_ACTUAL = N'00'
					)
					
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
