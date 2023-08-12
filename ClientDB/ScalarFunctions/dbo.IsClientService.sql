USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[IsClientService]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[IsClientService] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE OR ALTER FUNCTION [dbo].[IsClientService]
(
	@CLIENT	INT,
	@START	SMALLDATETIME,
	@FINISH	SMALLDATETIME
)
RETURNS BIT
AS
BEGIN
	DECLARE @RES BIT

	IF EXISTS
		(
			SELECT *
			FROM dbo.ClientTable
			WHERE (ClientID = @CLIENT OR ID_MASTER = @CLIENT)
				AND ClientLast BETWEEN @START AND @FINISH
				AND StatusID = 2
		)
		SET @RES = 1
	ELSE
	BEGIN
		IF
			(
				SELECT TOP 1 StatusID
				FROM dbo.ClientTable
				WHERE (ClientID = @CLIENT OR ID_MASTER = @CLIENT)
					AND ClientLast <= @START
				ORDER BY ClientLast DESC
			) = 2
			SET @RES = 1
		ELSE
			SET @RES = 0
	END

	RETURN @RES
END
GO
