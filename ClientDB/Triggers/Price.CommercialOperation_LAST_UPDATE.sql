USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE TRIGGER [Price].[CommercialOperation_LAST_UPDATE]
		ON Price.CommercialOperation
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = 'CommercialOperation' AND ReferenceSchema = 'Price'