USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EIS@Prepare(Internal)]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[EIS@Prepare(Internal)] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [dbo].[EIS@Prepare(Internal)]
(
	@Act_Id		Int,
	@Invoice_Id	Int
)
RETURNS TABLE
AS
RETURN
(
    SELECT
		[File_Id]    = Cast((SELECT [NewId] FROM [dbo].[NewIdView]) AS VarChar(100)),
        [IdentGUId]  = Replace(Cast((SELECT [NewId] FROM [dbo].[NewIdView]) AS VarChar(100)), '-', '')
	-- TODO сделать исключение в функции, чтобы можно было ошибку кидать при проверке по act_id
)
GO
