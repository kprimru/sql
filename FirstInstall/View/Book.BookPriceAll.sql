USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Book].[BookPriceAll]
--WITH SCHEMABINDING
AS
	SELECT
		BP_ID_MASTER, BP_ID,
		HLF_ID, HLF_ID_MASTER, HLF_NAME,
		BP_PRICE,
		BP_DATE, BP_END, BP_REF
	FROM
		Book.BookPriceDetail	INNER JOIN
		Common.HalfLast			ON	HLF_ID_MASTER	=	BP_ID_HALFGO
