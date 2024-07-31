Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
        Title="PublinedEV Tool" Height="600" Width="1000">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="*" />
            <RowDefinition Height="Auto" />
            <RowDefinition Height="Auto" />
        </Grid.RowDefinitions>
        
        <TextBlock Name="MyTextBlock" Text="PublinedEV Tool" 
                   FontSize="70" FontWeight="Bold"
                   VerticalAlignment="Top" HorizontalAlignment="Center" 
                   Foreground="White" Grid.Row="0" Margin="0,30,0,0">
            <TextBlock.Effect>
                <DropShadowEffect Color="Purple" Direction="315" ShadowDepth="4" BlurRadius="8"/>
            </TextBlock.Effect>
        </TextBlock>
        
        <Button Name="StartButton" Content="Start" Width="100" Height="40" 
                HorizontalAlignment="Center" VerticalAlignment="Top" 
                Grid.Row="1" Margin="0,200,0,0"/>  <!-- Dịch lên 200 px -->

        <TextBlock Name="StatusTextBlock" Text="Checking Python..." 
                   FontSize="16" FontWeight="Bold"
                   Foreground="White" VerticalAlignment="Bottom" HorizontalAlignment="Center"
                   Grid.Row="2" Margin="0,10,0,0"/>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load($reader)

$iconPath = (Resolve-Path "img/myicon.ico").Path
$Window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create([System.Uri]::new($iconPath))

$imagePath = (Resolve-Path "img/background.jpg").Path
$imageBrush = New-Object System.Windows.Media.ImageBrush
$imageBrush.ImageSource = [System.Windows.Media.Imaging.BitmapImage]::new([System.Uri]::new($imagePath))
$Window.FindName("MyTextBlock").Parent.Background = $imageBrush

$pythonPath = (Get-Command python -ErrorAction SilentlyContinue).Source

if ($pythonPath) {
    $Window.FindName("StatusTextBlock").Text = "Python is installed."
    $Window.FindName("StatusTextBlock").Foreground = [System.Windows.Media.Brushes]::Green
} else {
    $Window.FindName("StatusTextBlock").Text = "Python is not installed."

    $result = [System.Windows.MessageBox]::Show("Python is not installed. Do you want to install it now?", "Python Installation", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)

    if ($result -eq [System.Windows.MessageBoxResult]::Yes) {
        $installerPath = "https://www.python.org/ftp/python/3.9.6/python-3.9.6-amd64.exe"
        $tempPath = [System.IO.Path]::GetTempFileName() + ".exe"
        Invoke-WebRequest -Uri $installerPath -OutFile $tempPath

        Start-Process -FilePath $tempPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
        Remove-Item $tempPath

        [System.Windows.MessageBox]::Show("Python has been installed. Please restart the PowerShell.", "Installation Complete", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        $Window.Close()
    } else {
        $Window.FindName("StatusTextBlock").Foreground = [System.Windows.Media.Brushes]::Red
    }
}

$Window.FindName("StartButton").Add_Click({
    $exePath = "path\to\your\program.exe"  # Thay đổi đường dẫn đến tệp .exe của bạn
    Start-Process -FilePath $exePath
})

$Window.ShowDialog()
