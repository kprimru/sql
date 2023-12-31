USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Client].[CompanyActiveView]
WITH SCHEMABINDING
AS
    SELECT ID, ID_MASTER, SHORT, NAME, NUMBER, ID_PAY_CAT, ID_WORK_STATE, ID_POTENTIAL, ID_ACTIVITY, ACTIVITY_NOTE, ID_SENDER, SENDER_NOTE, ID_NEXT_MON, WORK_DATE, DELETE_COMMENT, ID_AVAILABILITY, ID_TAXING, ID_WORK_STATUS, ID_CHARACTER, ID_REMOTE, EMAIL, BLACK_LIST, BLACK_NOTE, STATUS, BDATE, EDATE, OLD_ID, UPD_USER, WORK_BEGIN, CARD, PAPER_CARD, ID_PROJECT, DEPO_NUM, DEPO
    FROM Client.Company
    WHERE STATUS IN (1, 3)

GO
CREATE UNIQUE CLUSTERED INDEX [IX_CLUST] ON [Client].[CompanyActiveView] ([ID] ASC);
GO
