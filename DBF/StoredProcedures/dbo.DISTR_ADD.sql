USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[DISTR_ADD] 
	@systemid INT,
	@distrnum INT,
	@compnum TINYINT,
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @distrid INT	

	INSERT INTO dbo.DistrTable (DIS_ID_SYSTEM, DIS_NUM, DIS_COMP_NUM, DIS_ACTIVE)
	VALUES (@systemid, @distrnum, @compnum, @active)	

	SELECT @distrid = SCOPE_IDENTITY() 	

	INSERT INTO dbo.DistrDocumentTable
					(
						DD_ID_DISTR, DD_ID_DOC, DD_PRINT, DD_ID_GOOD, DD_ID_UNIT
					)
		SELECT @distrid, DSD_ID_DOC, DSD_PRINT, DSD_ID_GOOD, DSD_ID_UNIT
		FROM 
			dbo.DocumentSaleObjectDefaultTable INNER JOIN
			dbo.SaleObjectTable ON DSD_ID_SO = SO_ID INNER JOIN
			dbo.SystemTable ON SYS_ID_SO = SO_ID
		WHERE SYS_ID = @systemid
	

	IF EXISTS
		(
			SELECT DIS_ID
			FROM dbo.DistrView
			WHERE DIS_NUM = @distrnum
				AND DIS_COMP_NUM = @compnum
				AND HST_ID = 
					(
						SELECT SYS_ID_HOST 
						FROM dbo.SystemTable 
						WHERE SYS_ID = @systemid
					)
				AND DIS_ID <> @distrid
		)
		BEGIN
			INSERT INTO dbo.ClientDistrTable
				SELECT CD_ID_CLIENT, @distrid, NULL, CD_ID_SERVICE
				FROM dbo.ClientDistrTable
				WHERE CD_ID_DISTR = 
					(
						SELECT DIS_ID
						FROM dbo.DistrView
						WHERE DIS_NUM = @distrnum
							AND DIS_COMP_NUM = @compnum
							AND HST_ID = 
								(
									SELECT SYS_ID_HOST 
									FROM dbo.SystemTable 
									WHERE SYS_ID = @systemid
								)
							AND DIS_ID <> @distrid
					)

			INSERT INTO dbo.TODistrTable
				SELECT @distrid, TD_ID_TO, 0
				FROM dbo.TODistrTable
				WHERE TD_ID_DISTR IN
					(
						SELECT DIS_ID
						FROM dbo.DistrView
						WHERE DIS_NUM = @distrnum
							AND DIS_COMP_NUM = @compnum
							AND HST_ID = 
								(
									SELECT SYS_ID_HOST 
									FROM dbo.SystemTable 
									WHERE SYS_ID = @systemid
								)
							AND DIS_ID <> @distrid
					)			
				

			--Удалить все остальные дистрибутивы с таким же хостом и номером
			DELETE 
			FROM dbo.TODistrTable
			WHERE TD_ID_DISTR IN
				(
					SELECT DIS_ID
					FROM dbo.DistrView
					WHERE DIS_NUM = @distrnum
						AND DIS_COMP_NUM = @compnum
						AND HST_ID = 
							(
								SELECT SYS_ID_HOST 
								FROM dbo.SystemTable 
								WHERE SYS_ID = @systemid
							)
						AND DIS_ID <> @distrid
				)			
			
			
			DELETE 
			FROM dbo.ClientDistrTable
			WHERE CD_ID_DISTR IN
				(
					SELECT DIS_ID
					FROM dbo.DistrView
					WHERE DIS_NUM = @distrnum
						AND DIS_COMP_NUM = @compnum
						AND HST_ID = 
							(
								SELECT SYS_ID_HOST 
								FROM dbo.SystemTable 
								WHERE SYS_ID = @systemid
							)
						AND DIS_ID <> @distrid
				)
		END

	IF @returnvalue = 1
		SELECT @distrid AS NEW_IDEN
		
	SET NOCOUNT OFF
END











