USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_KIND_UPDATE]
	@Id			SmallInt,
	@Name		VarChar(100),
	@SortIndex	SmallInt
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ClientKind
	SET Name		= @Name,
		SortIndex	= @SortIndex
	WHERE Id = @Id
END
