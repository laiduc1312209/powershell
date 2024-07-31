Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
        Title="PublinedEV Tool" Height="600" Width="1000">
    <Grid>
        <!-- Xác định hai hàng cho Grid -->
        <Grid.RowDefinitions>
            <RowDefinition Height="*" /> <!-- Hàng trên cho chữ -->
            <RowDefinition Height="Auto" /> <!-- Hàng dưới cho chữ trạng thái -->
        </Grid.RowDefinitions>

        <!-- Chữ PublinedEV Tool với kích thước lớn -->
        <TextBlock Name="MyTextBlock" Text="PublinedEV Tool" 
                   FontSize="70" FontWeight="Bold"
                   VerticalAlignment="Top" HorizontalAlignment="Center" 
                   Foreground="White" Grid.Row="0" Margin="0,30,0,0"/>

        <!-- Chữ trạng thái nằm ngay dưới chữ lớn -->
        <TextBlock Name="StatusTextBlock" Text="Checking Python..." 
                   FontSize="16" FontWeight="Bold"
                   Foreground="White" VerticalAlignment="Bottom" HorizontalAlignment="Center"
                   Grid.Row="1" Margin="0,10,0,0"/>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Thiết lập icon sau khi tạo cửa sổ
$iconPath = (Resolve-Path "myicon.ico").Path
$Window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create([System.Uri]::new($iconPath))

# Thiết lập hình nền sau khi tạo cửa sổ
$imagePath = (Resolve-Path "background.jpg").Path
$imageBrush = New-Object System.Windows.Media.ImageBrush
$imageBrush.ImageSource = [System.Windows.Media.Imaging.BitmapImage]::new([System.Uri]::new($imagePath))
$Window.Background = $imageBrush

# Kiểm tra trạng thái cài đặt Python
$pythonVersion = & python --version 2>&1 | Out-String

if ($pythonVersion -match "Python (\d+\.\d+\.\d+)") {
    $Window.FindName("StatusTextBlock").Text = "Python is installed. Version: $($matches[1])"
    $Window.FindName("StatusTextBlock").Foreground = [System.Windows.Media.Brushes]::Green
} else {
    $Window.FindName("StatusTextBlock").Text = "Python is not installed."

    # Hỏi người dùng có muốn cài đặt Python không
    $result = [System.Windows.MessageBox]::Show("Python is not installed. Do you want to install it now?", "Python Installation", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)

    if ($result -eq [System.Windows.MessageBoxResult]::Yes) {
        # Cài đặt Python
        $installerPath = "https://www.python.org/ftp/python/3.9.6/python-3.9.6-amd64.exe"
        $tempPath = [System.IO.Path]::GetTempFileName() + ".exe"
        Invoke-WebRequest -Uri $installerPath -OutFile $tempPath

        # Chạy trình cài đặt Python
        Start-Process -FilePath $tempPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

        # Xóa tệp cài đặt sau khi hoàn tất
        Remove-Item $tempPath

        [System.Windows.MessageBox]::Show("Python has been installed. Please restart the application.", "Installation Complete", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        $Window.Close()
    } else {
        $Window.FindName("StatusTextBlock").Foreground = [System.Windows.Media.Brushes]::Red
    }
}

$Window.ShowDialog()
