USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InfoBankSize]
(
        [IBS_ID_FILE]   Int                NOT NULL,
        [IBS_DATE]      SmallDateTime      NOT NULL,
        [IBS_SIZE]      bigint             NOT NULL,
        CONSTRAINT [PK_dbo.InfoBankSize] PRIMARY KEY CLUSTERED ([IBS_ID_FILE],[IBS_DATE]),
        CONSTRAINT [FK_dbo.InfoBankSize(IBS_ID_FILE)_dbo.InfoBankFile(IBF_ID)] FOREIGN KEY  ([IBS_ID_FILE]) REFERENCES [dbo].[InfoBankFile] ([IBF_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.InfoBankSize(IBS_DATE)+(IBS_ID_FILE,IBS_SIZE)] ON [dbo].[InfoBankSize] ([IBS_DATE] ASC) INCLUDE ([IBS_ID_FILE], [IBS_SIZE]);
GO
