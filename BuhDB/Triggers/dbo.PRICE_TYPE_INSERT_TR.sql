USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[PRICE_TYPE_INSERT_TR]
   ON  [dbo].[PriceType]
   AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

    EXEC [dbo].[REFERENCES_RELOAD]
END
GO
