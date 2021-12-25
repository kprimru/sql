USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DOC_EDITING_STATUS]
(
        [docid]         NVarChar(256)      NOT NULL,
        [spid]          SmallInt           NOT NULL,
        [hostname]      nchar(256)         NOT NULL,
        [hostprocess]   nchar(16)          NOT NULL,
        [loginame]      nchar(256)         NOT NULL,
        [login_time]    DateTime           NOT NULL,
        [tablename]     nchar(256)         NOT NULL,
        [ntname]        nchar(256)         NOT NULL,
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.DOC_EDITING_STATUS(docid,tablename)] ON [dbo].[DOC_EDITING_STATUS] ([docid] ASC, [tablename] ASC);
GO
GRANT DELETE ON [dbo].[DOC_EDITING_STATUS] TO DBAdministrator;
GRANT INSERT ON [dbo].[DOC_EDITING_STATUS] TO DBAdministrator;
GRANT SELECT ON [dbo].[DOC_EDITING_STATUS] TO DBAdministrator;
GRANT UPDATE ON [dbo].[DOC_EDITING_STATUS] TO DBAdministrator;
GRANT DELETE ON [dbo].[DOC_EDITING_STATUS] TO DBCount;
GRANT INSERT ON [dbo].[DOC_EDITING_STATUS] TO DBCount;
GRANT SELECT ON [dbo].[DOC_EDITING_STATUS] TO DBCount;
GRANT UPDATE ON [dbo].[DOC_EDITING_STATUS] TO DBCount;
GRANT DELETE ON [dbo].[DOC_EDITING_STATUS] TO DBPrice;
GRANT INSERT ON [dbo].[DOC_EDITING_STATUS] TO DBPrice;
GRANT SELECT ON [dbo].[DOC_EDITING_STATUS] TO DBPrice;
GRANT UPDATE ON [dbo].[DOC_EDITING_STATUS] TO DBPrice;
GRANT DELETE ON [dbo].[DOC_EDITING_STATUS] TO DBPriceReader;
GRANT INSERT ON [dbo].[DOC_EDITING_STATUS] TO DBPriceReader;
GRANT SELECT ON [dbo].[DOC_EDITING_STATUS] TO DBPriceReader;
GRANT UPDATE ON [dbo].[DOC_EDITING_STATUS] TO DBPriceReader;
GO
