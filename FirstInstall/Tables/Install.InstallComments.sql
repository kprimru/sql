USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Install].[InstallComments]
(
        [IC_ID]       UniqueIdentifier      NOT NULL,
        [IC_ID_IND]   UniqueIdentifier      NOT NULL,
        [IC_USER]     VarChar(50)           NOT NULL,
        [IC_DATE]     DateTime              NOT NULL,
        [IC_TEXT]     VarChar(Max)          NOT NULL,
        CONSTRAINT [PK_InstallComments] PRIMARY KEY CLUSTERED ([IC_ID]),
        CONSTRAINT [FK_InstallComments_InstallDetail] FOREIGN KEY  ([IC_ID_IND]) REFERENCES [Install].[InstallDetail] ([IND_ID])
);
GO
CREATE NONCLUSTERED INDEX [IC_ID_IND] ON [Install].[InstallComments] ([IC_ID_IND] ASC, [IC_DATE] ASC) INCLUDE ([IC_TEXT]);
GO
